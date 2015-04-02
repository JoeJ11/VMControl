class Experiment < ActiveRecord::Base
  belongs_to :cluster_configuration
  belongs_to :course

  STATUS_ONLINE = 1
  STATUS_OFFLINE = 0

  MACHINE_QUOTA = 3

  def start
    self.status = STATUS_ONLINE
    self.save
    params = {
        :cluster_configuration_id => self.cluster_configuration_id
    }
    MACHINE_QUOTA.times do
      Delayed::Job.enqueue(MachineCreateJob.new(params))
    end
    # MACHINE_QUOTA.times do
    #   machine = Machine.new(params)
    #   machine.start
    # end
  end

  def stop
    self.status = STATUS_OFFLINE
    self.save

    machines = self.cluster_configuration.machines
    tem_number = self.cluster_configuration.machine_number
    tem_limit = MACHINE_QUOTA * (self.cluster_configuration.experiments.size)
    machines.each do |machine|
      if machine.status == Machine::STATUS_ERROR
        Delayed::Job.enqueue(MachineDeleteJob.new(machine.id))
      elsif tem_number > tem_limit and machine.status == Machine::STATUS_AVAILABLE
        Delayed::Job.enqueue(MachineDeleteJob.new(machine.id))
        tem_number = tem_number - 1
      end
    end
  end

end
