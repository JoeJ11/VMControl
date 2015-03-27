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
    Delayed::Job.enqueue(MachineDeleteJob.new(self.cluster_configuration_id))
  end

end
