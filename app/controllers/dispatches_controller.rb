class DispatchesController < ApplicationController
  before_action :set_machines, only: [:stop, :start, :progress, :destroy]

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

  # def assign
  #   machine_apply_params = params.permit(:pub_key, :pri_key, :user_name, :exp_name, :params)
  #   if machine_apply_params[:pub_key] and machine_apply_params[:pub_key].class == String
  #     machine_apply_params[:pub_key] = StringIO.new(machine_apply_params[:pub_key])
  #   end
  #   if machine_apply_params[:pri_key] and machine_apply_params[:pri_key].class == String
  #     machine_apply_params[:pri_key] = StringIO.new(:machine_apply_params[:pri_key])
  #   end
  #   exp = Experiment.where("name='#{machine_apply_params[:exp_name]}'")
  #   exp = exp[0] if exp.size > 0
  #   # exp = Experiment.find_last_by_name(machine_apply_params[:exp_name])
  #   machine = nil
  #   exp.cluster_configuration.machines.each do |m|
  #     if m.status == CloudToolkit::STATUS_AVAILABLE
  #       machine = m
  #     end
  #   end
  #   rtn = machine ? machine.assign(machine_apply_params) : 'No available machines now.'
  #   render json: {notice: rtn}
  # end

  def service
    apply_params = params.permit(:user_name, :exp_id)

    # Check User name is a email address
    user_name = apply_params[:user_name]
    unless /(.+)@(.+)\.(.+)/.match(user_name)
      @machine = -1
      @message = 'Email Not Valid.'
      render :service and return
    end

    # Set up Account locally
    info = Student.setup(apply_params[:user_name])

    # Set up Account Remotely
    unless Machine.validate_user(user_name)
      @machine = -1
      @message = 'A remote account has been setup. Password thumooc123'
      render :service and return
    end

    # Get experiment Information
    exp = Experiment.find apply_params[:exp_id].to_i
    info[:exp] = exp

    # Assign Machine
    machine = nil
    exp.cluster_configuration.machines.each do |m|
      if m.status == CloudToolkit::STATUS_AVAILABLE
        machine = m
      end
    end
    if machine
      machine.user_name = info[:user_name]
      machine.status = CloudToolkit::STATUS_ONPROCESS
      machine.progress = 0
      machine.save

      machine.delay.assign(info)
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
      puts @machine.progress
      render json: { :progress => 3, :url => @machine.url}
    else
      puts @machine.progress
      render json: { :progress => @machine.progress }
    end
  end

end
