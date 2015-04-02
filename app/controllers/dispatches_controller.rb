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

  def service
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
    machine_apply_params = params.require(:cluster_configuration).permit(:pub_key, :pri_key, :user_name, :exp_name, :params)
    exp = Experiment.find_last_by_name(machine_apply_params[:exp_name])
    machine = nil
    exp.cluster_configuration.machines.each do |m|
      if m.status == CloudToolkit::STATUS_AVAILABLE
        machine = m
      end
    end
    rtn = machine ? machine.assign(machine_apply_params) : 'No available machines now.'
    render json: {notice: rtn}
  end

end
