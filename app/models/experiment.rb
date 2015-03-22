class Experiment < ActiveRecord::Base
  belongs_to :cluster_configuration
  belongs_to :course

  STATUS_ONLINE = 1
  STATUS_OFFLINE = 0

  MACHINE_QUOTA = 5

  def start
    self.status = STATUS_ONLINE
    self.save
    params = {
        :setting => self.cluster_configuration.specifier,
        :cluster_configuration_id => self.cluster_configuration.id,
        :status => Machine::STATUS_OCCUPIED
    }
    MACHINE_QUOTA.times do
      machine = Machine.new(params)
      machine.start
    end
  end

  def stop
    self.status = STATUS_OFFLINE
    self.save
    Delayed::Job.enqueue(MachineDeleteJob.new(self.cluster_configuration_id))
  end

end
