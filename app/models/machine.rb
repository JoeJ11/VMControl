class Machine < ActiveRecord::Base
  include CloudToolkit
  belongs_to :cluster_configuration

  MAXIMUM_MACHINES = 20

  # Start / Create a machine
  def start
    setting = {'config_id' => self.setting, 'cluster_number' => 1}
    config = create_machine setting
    if config['status'] == 'CREATE_COMPLETE'
      self.status = STATUS_AVAILABLE
      self.ip_address = config[:ip_address]
    elsif config['status'] == 'CREATE_IN_PROGRESS'
      self.status = STATUS_ONPROCESS
    else
      self.status = STATUS_ERROR
    end
    self.save
  end

  # Stop / Delete a machine
  def stop
    stop_machine
    self.status = STATUS_ONPROCESS
    self.student_id = 0
    self.save
  end

  # Restart machine
  def restart
    self.stop
    self.start
  end

  # Assign a machine to a student
  def assign (info)
    user_name = info[:user_name]
    unless /(.+)@(.+)\.(.+)/.match(user_name)
      return {error: "Not an email!"}
    end
    unless validate_user(user_name)
      return {error: "Email not valid!"}
    end
    setup_environment info

    self.user_name = user_name
    self.status = STATUS_OCCUPIED
    self.save

    Delayed::Job.enqueue(MachineControlJob.new(self.id), 10, 5.minute.from_now)
    params = {
        :cluster_configuration_id => self.cluster_configuration.id
    }
    Delayed::Job.enqueue(MachineCreateJob.new(params))
    {external_ip: self.ip_address}
  end

  # Create a machine
  # Not used now!
  def new_machine
    self.start
  end

  def check_setting_valid
  end

  def setup_environment info
    set_uo_keys info
    # execute_playbook cluster_configuration.name, ip_address
  end

  def set_uo_keys info
    public_key = open(Rails.root.join('playbook', 'tmp' ,'pub_key'), 'w')
    public_key.write(info[:pub_key].read)
    public_key.close()
    private_key = open(Rails.root.join('playbook', 'tmp', 'pri_key'), 'w')
    private_key.write(info[:pri_key].read)
    private_key.close()
  end

  def execute_playbook name, ip_address
    base_address = Rails.root.join('playbook').to_s
    cmd = 'ansible-playbook '
    cmd += '-i ' + base_address + '/hosts '
    cmd += base_address + '/playbooks/' + name + '.yml '
    cmd += '-e ' + 'host=' + ip_address
    # puts cmd
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts('cd ' + Rails.root.join('playbook').to_s)
      stdin.puts(cmd)
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR'
      puts stderr.read.strip
    end
  end
  # Auto-release a machine
  # def auto_release(student_id)
  #  if self.status == CloudToolkit::STATUS_OCCUPIED and self.student_id == student_id
  #    self.restart
  #  end
  # end
  # handle_asynchronously :auto_release, :run_at => Proc.new { 1.minute.from_now }

end
