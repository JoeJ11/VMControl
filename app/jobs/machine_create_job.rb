class MachineCreateJob < Struct.new(:num, :params)

  def perform
    config = ClusterConfiguration.find(params[:cluster_configuration_id])
    if config and config.machines.size < Machine::MAXIMUM_MACHINES
      machine = Machine.new(params)
      machine.start
      Delayed::Job.enqueue(MachineCreateJob.new(num-1, params))
    end
  end

end