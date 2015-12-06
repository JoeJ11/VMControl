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
        begin
          # ActiveRecord::Base.establish_connection Rails.env
          if machine.ip_address
            machine.stop_proxy(machine.ip_address)
            machine.stop_proxy("#{machine.ip_address}:5000")
            machine.stop_proxy("#{machine.ip_address}:4040")
            machine.cleanup_after_stop
          end

          machine.stop

          Delayed::Job.enqueue(MachineDeleteJob.new(machine_id), 10, 30.seconds.from_now)
        ensure
          ActiveRecord::Base.connection.close
        end
      end
    elsif status == CloudToolkit::STATUS_ONPROCESS
      machine.stop
      Delayed::Job.enqueue(MachineDeleteJob.new(machine_id), 10, 30.seconds.from_now)

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
