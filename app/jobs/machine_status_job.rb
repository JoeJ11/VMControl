class MachineStatusJob < Struct.new(:machine_id)

  def perform
    machine = Machine.find machine_id
    if machine
      information = machine.show_machine
      if information[:status] == CloudToolkit::STATUS_AVAILABLE
        machine.status = CloudToolkit::STATUS_PREPARE
        machine.ip_address = information[:ip_address]
        machine.save
      elsif information[:status] == CloudToolkit::STATUS_ONPROCESS
        Delayed::Job.enqueue(MachineStatusJob.new(machine_id), 10, 10.seconds.from_now)
      elsif information[:status] == CloudToolkit::STATUS_ERROR
        machine.status = CloudToolkit::STATUS_ERROR
        machine.save
      end
    end
  end
end