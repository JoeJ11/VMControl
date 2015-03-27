class MachineDeleteJob < Struct.new(:configuration_id)

  def perform
    config = ClusterConfiguration.find configuration_id
    if config
      machines = config.machines
      expected_number = Experiment::MACHINE_QUOTA * (config.experiments.size)
      if machines.size > Machine::MAXIMUM_MACHINES or machines.size > expected_number
        machine = Machine.find_by_status Machine::STATUS_AVAILABLE
        if machine
          machine.stop
          machine.destroy
          Delayed::Job.enqueue(MachineDeleteJob.new(configuration_id))
        else
          Delayed::Job.enqueue(MachineDeleteJob.new(configuration_id, 1, 1.hour.from_now))
        end
      end
    end
  end

end