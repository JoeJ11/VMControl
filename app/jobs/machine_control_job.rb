class MachineControlJob < Struct.new(:machine_id)

  def perform
    machine = Machine.find(machine_id)
    if machine and machine.status == CloudToolkit::STATUS_OCCUPIED
      machine.stop
      machine.destroy
      Delayed::Job.enqueue(MachineDeleteJob.new(machine.cluster_configuration.id))
    end
  end
end