class MachineStatusJob < Struct.new(:machine_id, :counter=0)

  def perform
    machine = Machine.find machine_id
    if machine
      information = machine.show_machine
      if information[:status] == CloudToolkit::STATUS_AVAILABLE
        machine.status = CloudToolkit::STATUS_PREPARE
        machine.ip_address = information[:ip_address]
        machine.save

        Thread.new do
          # ActiveRecord::Base.establish_connection Rails.env
          sleep(60.seconds)
          begin
            if machine.setup_after_creation == 0
              Rails.logger.info 'Machine Creation Success.'
              machine.status = CloudToolkit::STATUS_AVAILABLE
              machine.save
            else
              if counter > 3
                Rails.logger.error 'Machine Creation Fail.'
                machine.status = CloudToolkit::STATUS_ERROR
                machine.save
              else
                Rails.logger.info 'Try to setup again'
                Delayed::Job.enqueue(MachineStatusJob.new(machine_id, counter+1), 10, 60.seconds.from_now)
              end
            end
          rescue => exception
            Rails.logger.error exception.inspect
            machine.status = CloudToolkit::STATUS_ERROR
            machine.save
          end
          # sleep(10.seconds)
          ActiveRecord::Base.connection.close
        end

      elsif information[:status] == CloudToolkit::STATUS_ONPROCESS
        Delayed::Job.enqueue(MachineStatusJob.new(machine_id), 10, 10.seconds.from_now)

      elsif information[:status] == CloudToolkit::STATUS_ERROR
        machine.status = CloudToolkit::STATUS_ERROR
        machine.save
      end
    end
  end
end
