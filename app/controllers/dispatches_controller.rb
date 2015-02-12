class DispatchesController < ApplicationController
  before_action :set_machines, only: [:stop, :start, :progress]

  def index
    @machines = Machine.all
  end

  def list
  end

  def new
    @machine = Machine.new
  end

  def stop
    debugger
    @machine.stop
  end

  def progress
  end

  def service
  end

  def start
    @machine.start
  end

  def create
    @machine = Machine.new()
    # @machine.ip_address = params[:machines][:ip_address]
    @machine.setting = params[:machines][:setting]
    @machine.group = params[:machines][:group]
    @machine.status = Machine::STATUS_OCCUPIED
    #@machine.set_tenant_name params[:machines][:tenant_name]

    @machine.new_machine

    respond_to do |format|
      if @machine.save
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


end
