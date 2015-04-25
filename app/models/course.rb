class Course < ActiveRecord::Base

  include GitToolkit

  def setup
    create_git_user("Teacher_#{self.teacher}", self.teacher)
    add_ssh_key
  end

  def setup_repo(exp_name)
    code_id = create_repo("#{exp_name}_code")
    config_id = create_repo("#{exp_name}_config")
    initialize_repo exp_name
    push_to_remote exp_name
    # config_id = fork_repo(1)
    # change_name(config_id, "#{exp_name}_config")
    return {:code => code_id, :config => config_id}
  end

  def initialize_repo(exp_name)
    Dir.chdir(Rails.root.join('ansible', 'roles'))
    Dir.mkdir(exp_name)
    FileUtils.cp_r 'sample/.', exp_name
  end

  def push_to_remote(exp_name)
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts 'cd ' + Rails.root.join('ansible', 'roles', exp_name).to_s
      stdin.puts 'git init'
      stdin.puts 'git add .'
      stdin.puts 'git commit -am "first commit."'
      stdin.puts 'git remote add origin git@THUVMControl.cloudapp.net:Teacher_' + teacher + '/' + exp_name.downcase + '_config.git'
      stdin.puts 'git push -u origin master'
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end
end
