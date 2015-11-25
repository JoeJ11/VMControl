class MachineControlJob < Struct.new(:machine_id)

  def perform
    machine = Machine.find(machine_id)
    if machine and machine.status == CloudToolkit::STATUS_OCCUPIED
      machine.stop_proxy(self.ip_address)
      machine.stop_proxy("#{self.ip_address}:5000")
      machine.stop_proxy("#{self.ip_address}:8080")
      machine.cleanup_after_stop
      machine.stop
      machine.destroy
      machine.cluster_configuration.machines.each do |m|
        if m.status == CloudToolkit::STATUS_ERROR
          Delayed::Job.enqueue(MachineDeleteJob.new(m.id))
        end
      end
    end
  end
end
