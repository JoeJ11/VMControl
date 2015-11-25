class Experiment < ActiveRecord::Base
  include GitToolkit

  belongs_to :cluster_configuration
  belongs_to :course

  STATUS_ONLINE = 1
  STATUS_OFFLINE = 0

  MACHINE_QUOTA = 10

  def start
    self.status = STATUS_ONLINE
    self.save
    params = {
        :cluster_configuration_id => self.cluster_configuration_id
    }
    MACHINE_QUOTA.times do
      Delayed::Job.enqueue(MachineCreateJob.new(params))
    end
  end

  def stop
    self.status = STATUS_OFFLINE
    self.save

    self.cluster_configuration.machines.each do |m|
        Delayed::Job.enqueue(MachineDeleteJob.new(m.id))
    end
    # machines = self.cluster_configuration.machines
    # tem_number = self.cluster_configuration.machine_number
    # tem_limit = MACHINE_QUOTA * self.cluster_configuration.experiment_number
    # puts tem_number.to_s + '/' + tem_limit.to_s
    # machines.each do |machine|
    #   if machine.status == Machine::STATUS_ERROR
    #     Delayed::Job.enqueue(MachineDeleteJob.new(machine.id))
    #   elsif tem_number > tem_limit # and (machine.status == Machine::STATUS_AVAILABLE or machine.status == Machine::STATUS_OCCUPIED)
    #     Delayed::Job.enqueue(MachineDeleteJob.new(machine.id))
    #     tem_number = tem_number - 1
    #   end
    # end
  end

  def update_config_git
    Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts "cd #{Rails.root.join('ansible', 'roles', name).to_s}"
      stdin.puts 'git pull origin master'
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end

end
