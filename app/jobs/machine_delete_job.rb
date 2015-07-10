class MachineDeleteJob < Struct.new(:machine_id)

  def perform
    machine = Machine.find machine_id
    if machine
      status = machine.show_machine[:status]
    else
      return
    end
    if status == CloudToolkit::STATUS_OCCUPIED or status == CloudToolkit::STATUS_AVAILABLE
      Thread.new do
        # ActiveRecord::Base.establish_connection Rails.env
        machine.stop_proxy
        machine.cleanup_after_stop
        machine.stop

        Delayed::Job.enqueue(MachineDeleteJob.new(machine_id), 10, 10.seconds.from_now)
        # ActiveRecord::Base.connection.close
      end
    elsif status == CloudToolkit::STATUS_ONPROCESS
      Delayed::Job.enqueue(MachineDeleteJob.new(machine_id), 10, 10.seconds.from_now)

    elsif status == CloudToolkit::STATUS_ERROR
      machine.stop
      fail
    else
      machine.destroy
    end
  end

  def max_attempts
    3
  end
end