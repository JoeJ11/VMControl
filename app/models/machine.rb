class Machine < ActiveRecord::Base
  include CloudToolkit
  belongs_to :cluster_configuration

  MAXIMUM_MACHINES = 20

  # Start / Create a machine
  def start
    setting = {'config_id' => self.setting, 'cluster_number' => 1}
    create_machine setting
    # if config['status'] == 'CREATE_COMPLETE'
    #   self.status = STATUS_AVAILABLE
    #   self.ip_address = config[:ip_address]
    # elsif config['status'] == 'CREATE_IN_PROGRESS'
    #   self.status = STATUS_ONPROCESS
    # else
    #   self.status = STATUS_ERROR
    # end
    # self.save
  end

  # Stop / Delete a machine
  def stop
    if self.status == STATUS_OCCUPIED
      stop_proxy
    end

    self.delete_machine
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

    setup_proxy

    Delayed::Job.enqueue(MachineControlJob.new(self.id), 10, 5.minute.from_now)
    params = {
        :cluster_configuration_id => self.cluster_configuration.id
    }
    Delayed::Job.enqueue(MachineCreateJob.new(params))
    {external_ip: 'http://thuvmcontrol.cloudapp.net:8000/4201/'}
  end

  # Create a machine
  # Not used now!
  def new_machine
    self.start
  end

  def check_setting_valid
  end

  def setup_environment(info)
    keys_info = {
        :pri_key => info[:pri_key],
        :pub_key => info[:pub_key]
    }
    set_uo_keys keys_info

    load_config_repo info[:exp]

    student = Student.find_by_mail_address info[:user_name]
    student.setup_repo info[:exp].code_repo_id
    name = student.get_user['name']
    # code_repo = Student.list_repo info[:exp].code_repo_id
    code_repo = "http://THUVMControl.cloudapp.net/#{name}/#{info[:exp].name.downcase}_code.git"
    # execute_playbook ip_address, code_repo
    execute_playbook 'mooctesting2.cloudapp.net', code_repo
  end

  def set_uo_keys(info)
    public_key = open(Rails.root.join('playbook', 'tmp' ,'pub_key'), 'w')
    public_key.write(info[:pub_key].read)
    public_key.close()
    private_key = open(Rails.root.join('playbook', 'tmp', 'pri_key'), 'w')
    private_key.write(info[:pri_key].read)
    private_key.close()
  end

  def execute_playbook(ip_address, code_repo)
    base_address = Rails.root.join('playbook').to_s
    cmd = 'ansible-playbook '
    cmd += '-i ' + base_address + '/hosts '
    cmd += "#{base_address}/trial_project/main.yml "
    cmd += '-e ' + '"host=' + ip_address
    cmd += " git_repo=#{code_repo}\""
    puts cmd
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

  def load_config_repo(exp)
    repo = Student.list_repo(exp.config_repo_id)
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts("cd #{Rails.root.join('playbook').to_s}")
      stdin.puts("git clone http://thuvmcontrol.cloudapp.net/Teacher_#{exp.course.teacher}/trial_project.git")
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR'
      puts stderr.read.strip
    end
  end

  def setup_proxy
    base_address = Rails.root.join('playbook').to_s
    cmd = 'ansible-playbook '
    cmd += "-i #{base_address}/hosts "
    cmd += "#{base_address}/playbooks/proxy.yml "
    # cmd += "-e \"ip=#{self.ip_address} port=#{4201}\""
    cmd += '-e "ip=mooctesting2.cloudapp.net port=4201"'
    puts cmd
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts cmd
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end

  def stop_proxy
    base_address = Rails.root.join('playbook').to_s
    cmd = 'ansible-playbook '
    cmd += "-i #{base_address}/hosts "
    cmd += "#{base_address}/playbooks/proxy_stop.yml "
    cmd += '-e "port=4201"'
    puts cmd
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts cmd
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
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
