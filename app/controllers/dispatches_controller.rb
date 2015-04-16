class DispatchesController < ApplicationController
  before_action :set_machines, only: [:stop, :start, :progress]

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

  def progress
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

  def set_machines
    @machine = Machine.find(params[:id])
  end

  def assign
    machine_apply_params = params.permit(:pub_key, :pri_key, :user_name, :exp_name, :params)
    if machine_apply_params[:pub_key] and machine_apply_params[:pub_key].class == String
      machine_apply_params[:pub_key] = StringIO.new(machine_apply_params[:pub_key])
    end
    if machine_apply_params[:pri_key] and machine_apply_params[:pri_key].class == String
      machine_apply_params[:pri_key] = StringIO.new(:machine_apply_params[:pri_key])
    end
    exp = Experiment.where("name='#{machine_apply_params[:exp_name]}'")
    exp = exp[0] if exp.size > 0
    # exp = Experiment.find_last_by_name(machine_apply_params[:exp_name])
    machine = nil
    exp.cluster_configuration.machines.each do |m|
      if m.status == CloudToolkit::STATUS_AVAILABLE
        machine = m
      end
    end
    rtn = machine ? machine.assign(machine_apply_params) : 'No available machines now.'
    render json: {notice: rtn}
  end

  def service
    apply_params = params.permit(:user_name, :exp_id)
    info = Student.setup(apply_params[:user_name])
    exp = Experiment.find apply_params[:exp_id].to_i
    info[:exp] = exp

    machine = nil
    exp.cluster_configuration.machines.each do |m|
      if m.status == CloudToolkit::STATUS_AVAILABLE
        machine = m
      end
    end
    rtn = machine ? machine.assign(info) : {:error => 'No available machine now.'}
    if rtn.has_key? :external_ip
      render json: {:ip => rtn[:external_ip]}
    else
      render json: {:error => rtn[:error]}
    end
  end

end
