class MachineCreateJob < Struct.new(:params)

  def perform
    config = ClusterConfiguration.find params[:cluster_configuration_id]
    if config and config.machines.size < Machine::MAXIMUM_MACHINES
      new_params = {
          :setting => config.specifier,
          :cluster_configuration => config,
          :status => Machine::STATUS_OCCUPIED
      }
      machine = Machine.new(new_params)
      machine.start
    end
  end

end