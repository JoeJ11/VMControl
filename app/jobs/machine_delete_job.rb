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
          machine.status = Machine::STATUS_DELETED
          machine.save

          if machine.ip_address
            machine.stop_proxy(machine.ip_address)
            machine.stop_proxy("#{machine.ip_address}:8181")
            JSON.load(Experiment.find_by_cluster_configuration_id(machine.cluster_configuration_id).port).each do |port|
              stop_proxy("#{machine.ip_address}:#{port[1]}")
            end

            # machine.stop_proxy(machine.ip_address)
            # machine.stop_proxy("#{machine.ip_address}:5000")
            # machine.stop_proxy("#{machine.ip_address}:4040")
            machine.cleanup_after_stop
          end

          Delayed::Job.enqueue(MachineDeleteJob.new(machine_id), 10, 30.seconds.from_now)
        ensure
          machine.stop
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
