class DispatchesController < ApplicationController
  before_action :set_machines, only: [:stop, :start, :progress, :destroy]
  after_action :allow_iframe, only: [:service]

  def index
    @machines = Machine.all
  end

  def list
  end

  def new
    @machine = Machine.new
    @available_cluster_configs = []
    ClusterConfiguration.all.each do |p|
      if p.instantiated == 'true'
        @available_cluster_configs.push p.specifier
      end
    end
  end

  def stop
    if @machine.ip_address
      @machine.stop_proxy @machine.ip_address
      @machine.stop_proxy @machine.ip_address + ':5000'
      @machine.stop_proxy @machine.ip_address + ':8080'
      @machine.cleanup_after_stop
    end
    @machine.stop
    redirect_to :back
  end

  def start
    @machine.start
    redirect_to :back
  end

  def create
    @machine = Machine.new()
    @machine.setting = params[:machine][:setting]
    @machine.group = params[:machine][:group]
    @machine.status = Machine::STATUS_OCCUPIED

    respond_to do |format|
      if @machine.save
        @machine.start
        format.html {redirect_to :back, notice: "Machine Created!"}
      else
        format.html {redirect_to :back, notice: "Error! Machine Creation Failed!"}
      end
    end
  end

  def update
  end

  def destroy
    @machine.destroy
    redirect_to :back
  end

  def set_machines
    @machine = Machine.find(params[:id])
  end

  def service
    apply_params = params.permit(:user_name, :exp_id, :xuetang_id, :account_name, :anonym_id)

    if apply_params[:account_name].length < 4
      apply_params[:account_name] = apply_params[:account_name] + '____'
    end

    # Check User name is a email address
    user_name = apply_params[:user_name]
    unless /(.+)@(.+)\.(.+)/.match(user_name)
      @machine = -1
      @message = 'Email Not Valid.'
      render :service and return
    end

    # Set up Account locally
    info = Student.setup(apply_params[:user_name], apply_params[:account_name], apply_params[:anonym_id])

    # Set up Account Remotely
    unless Machine.validate_user(user_name)
      @machine = -1
      @message = 'Accounts are created. Please refresh the page!'
      render :service and return
    end

    # Get experiment Information
    exp = Experiment.find apply_params[:exp_id].to_i
    info[:exp] = exp

    # Check if there is a machine yet not released
    tem_m = nil
    exp.cluster_configuration.machines.each do |m|
      if m.user_name == info[:user_name]
        tem_m = m
      end
    end
    # tem_m = Machine.where("user_name = ? AND exp_id = ?", info[:user_name], info[:exp_id])
    # tem_m = Machine.find_all_by_user_name info[:user_name]
    if tem_m and tem_m.status != OsCloudToolkit::STATUS_ERROR and tem_m.status != OsCloudToolkit::STATUS_DELETED
      @machine = tem_m.id
      render :service and return
    end

    # Assign Machine
    machine = nil
    exp.cluster_configuration.machines.each do |m|
      if m.status == OsCloudToolkit::STATUS_AVAILABLE
        machine = m
      end
    end
    if machine
      machine.user_name = info[:user_name]
      machine.status = OsCloudToolkit::STATUS_ONPROCESS
      machine.progress = 0
      machine.save

      Thread.new do
        begin
          Rails.logger.info 'Machine Assign Starts'
          machine.assign(info)
        ensure
          ActiveRecord::Base.connection.close
        end
      end
      @machine = machine.id
      render :service
    else
      @machine = -1
      @message = 'No available machine.'
      render :service
    end
  end

  def progress
    if @machine.progress == 3
      url_map = JSON.load(@machine.url)
      if url_map.has_key?('GUI')
	base_url = url_map['GUI']
        # url_map['GUI'] = base_url+'vnc.html?host='+base_url[7..base_url.length]+'&port=6080&password=Mooc_2015'
	url_map['GUI'] = base_url + 'guacamole'
      end
      render json: { :progress => 3,
                     :url => url_map['shell'],
                     :editor_url => url_map['editor'],
                     :url_list => url_map}
    elsif @machine.progress == -1
      Delayed::Job.enqueue(MachineDeleteJob.new(@machine.id))

      render json: { :progress => @machine.progress }
    else
      render json: { :progress => @machine.progress }
    end
  end

  def get_xuetang_user(anonymous_id)
    response = HTTParty.get(
        "http://www.xuetangx.com/internal_api/check_anonymous?anonymous_id=#{anonymous_id}",
        :headers => {
            'XUETANGX-API-KEY' => '3nW28f2fS6CbztLERiYfQqHtC7ZhB8Y2'
        }
    )
    puts response
  end

  def file
    apply_params = params.permit(:exp_id, :anonym_id, :file_path, :ref)
    student = Student.find_by_anonym_id apply_params[:anonym_id]
    unless student
      render json: {:found => 'False', :message => 'User not found'}
    end
    git_user = student.get_user

    if apply_params.has_key? :ref
      ref = apply_params[:ref]
    else
      ref = 'master'
    end

    experiment = Experiment.find params[:exp_id]
    repo_name = "#{git_user['username']}%2F#{experiment.name.downcase}_code"
    response = Student.get_file repo_name, apply_params[:file_path], ref

    if response.code == 200
      render json: { :found => 'True', :content => response['content']}
    else
      render json: { :found => 'False', :message => 'Git server response error.'}
    end
  end

  # Allow iframe to be seen from xuetangX
  def allow_iframe
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end

end
