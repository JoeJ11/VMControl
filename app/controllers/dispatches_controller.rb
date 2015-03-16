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
    user_name = params[:user_name]
    flag = @machine.assign user_name
    if /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/.match(flag)
      render json: {external_ip: flag}
    else
      render json: {error: flag}
    end
  end

end
