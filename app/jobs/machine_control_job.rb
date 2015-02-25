class MachineControlJob < Struct.new(:machine_id)
  def perform
    machine = Machine.find(machine_id)
    if machine and machine.status == CloudToolkit::STATUS_OCCUPIED
      machine.restart
    end
  end
end