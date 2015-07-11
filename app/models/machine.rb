class Machine < ActiveRecord::Base
  include CloudToolkit
  include ProxyToolkit

  belongs_to :cluster_configuration

  MAXIMUM_MACHINES = 20

  # Start / Create a machine
  def start
    create_machine :config_id => self.setting, :cluster_number => 1
  end

  # Stop / Delete a machine
  def stop
    # self.stop_proxy
    # if machine_status and (machine_status == STATUS_AVAILABLE or machine_status == STATUS_OCCUPIED)
    #   self.cleanup_after_stop
    # end

    self.delete_machine
    self.status = STATUS_ERROR
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
    self.progress = 1
    self.save

    params = {
        :cluster_configuration_id => self.cluster_configuration.id
    }
    Delayed::Job.enqueue(MachineCreateJob.new(params))

    # This set up remote VM
    # Return value 0 means no error
    unless setup_environment(info) == 0
      self.progress = -1
      self.save
      return
    end

    self.progress = 2
    self.save

    # This starts the proxy
    self.url = start_proxy('mooc', ProxyToolkit::PROXY_SHELL_MODE)
    self.progress = 3
    self.status = STATUS_OCCUPIED
    self.save

    Delayed::Job.enqueue(MachineDeleteJob.new(self.id), 10, 120.minute.from_now)
  end

  # handle_asynchronously :assign, :priority => 100

  # Create a machine
  # Not used now!
  def new_machine
    self.start
  end

  def setup_environment(info)
    keys_info = {
        :pri_key => info[:pri_key],
        :pub_key => info[:pub_key]
    }
    set_uo_keys keys_info

    # load_config_repo info[:exp]

    student = Student.find_by_mail_address info[:user_name]
    repo_id = student.setup_repo info[:exp].code_repo_id
    student.publicize_repo(repo_id)
    user_info = student.get_user
    code_repo = "git@THUVMControl.cloudapp.net:#{user_info['username']}/#{info[:exp].name.downcase}_code.git"
    rtn_status = execute_playbook code_repo, user_info['username'], user_info['email'], info[:exp].name.downcase
    student.edit_repo(repo_id)
    return rtn_status
  end

  def set_uo_keys(info)
    public_key = open(Rails.root.join('ansible', 'roles' , 'common', 'files','pub_key'), 'w')
    public_key.write(info[:pub_key])
    public_key.close
    private_key = open(Rails.root.join('ansible', 'roles', 'common', 'files','pri_key'), 'w')
    private_key.write(info[:pri_key])
    private_key.close
  end

  def execute_playbook(code_repo, user_name, user_mail, exp)
    base_address = Rails.root.join('ansible').to_s
    cmd = 'ansible-playbook '
    cmd += '-i ' + base_address + '/hosts '
    cmd += "#{base_address}/machine.yml "
    cmd += '-e ' + '"host=' + self.ip_address
    cmd += " git_repo=#{code_repo}"
    cmd += " git_name=#{user_name}"
    cmd += " git_mail=#{user_mail}"
    cmd += " exp=#{exp}\""
    puts cmd
    Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts('export ANSIBLE_HOST_KEY_CHECKING=False')
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
    Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts("cd #{Rails.root.join('ansible').to_s}")
      stdin.puts("git clone http://thuvmcontrol.cloudapp.net/Teacher_#{exp.course.teacher}/trial_project.git")
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR'
      puts stderr.read.strip
    end
  end

  def setup_after_creation
    base_address = Rails.root.join('ansible').to_s
    cmd = 'ansible-playbook '
    cmd += "-i #{base_address}/hosts "
    cmd += "#{base_address}/machine_start.yml "
    cmd += '-e ' + '"host=' + ip_address
    cmd += " exp=#{self.cluster_configuration.experiment.name.downcase}\""
    puts cmd

    Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts('export ANSIBLE_HOST_KEY_CHECKING=False')
      stdin.puts(cmd)
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end

  def cleanup_after_stop
    base_address = Rails.root.join('ansible').to_s
    cmd = 'ansible-playbook '
    cmd += "-i #{base_address}/hosts "
    cmd += "#{base_address}/machine_stop.yml "
    cmd += '-e ' + '"host=' + ip_address
    if self.user_name
      cmd += " logname=#{self.user_name + Time.now.strftime("%d_%m_%Y_%H_%M")}.log"
    else
      cmd += " logname=Unknown#{Time.now.strftime("%d_%m_%Y_%H_%M")}"
    end
    cmd += " exp=#{self.cluster_configuration.experiment.name.downcase}\""
    puts cmd

    Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts('export ANSIBLE_HOST_KEY_CHECKING=False')
      stdin.puts(cmd)
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end

  def self.clear_errored
    Machine.list_machines.each do |m|
      m_i = Machine.new
      m_i.specifier = m['cluster_id']
      if m['status'] == 'CREATE_FAILED' or m['status'] == 'DELETE_FAILED'
        m_i.delete_machine
      end
    end
  end

  def self.clear_all
    Machine.list_machines.each do |m|
      m_i = Machine.new
      m_i.specifier = m['cluster_id']
      m_i.delete_machine
    end
  end


end
