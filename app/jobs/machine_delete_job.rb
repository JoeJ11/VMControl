class MachineDeleteJob < Struct.new(:machine_id)

  def perform
    machine = Machine.find machine_id
    if machine
      machine.stop
      sleep(5.seconds)
      while machine.show_machine == CloudToolkit::STATUS_ONPROCESS
        sleep(5.seconds)
      end
      if machine.show_machine == CloudToolkit::STATUS_ERROR
        fail
      end
      machine.destroy
    end
  end

  def max_attempts
    3
  end
end