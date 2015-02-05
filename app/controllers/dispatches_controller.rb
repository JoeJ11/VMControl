class DispatchesController < ApplicationController
  before_action :set_machines, only: [:stop, :start, :progress]

  def list
  end

  def new
    @machine = Machines.new
  end

  def stop
  end

  def progress
  end

  def service
  end

  def start
    @machine.start
  end

  def create
    @machine = Machines.new()
    @machine.ip_address = params[:machines][:ip_address]
    @machine.setting = params[:machines][:setting]
    @machine.status = Machines::STATUS_OCCUPIED
    @machine.group = params[:machines][:group]
    #@machine.set_tenant_name params[:machines][:tenant_name]

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
    @machine = Machines.find(params[:id])
  end


end
