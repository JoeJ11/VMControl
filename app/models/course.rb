class Course < ActiveRecord::Base

  include GitToolkit

  def setup
    create_git_user("Teacher_#{self.teacher}", self.teacher)
    add_ssh_key
  end

  def setup_repo(exp_name)
    # Create Code Repo
    code_id = create_repo("#{exp_name}_code")

    # Create config repo, which will be executed when assigned
    config_id = create_repo("#{exp_name}_config")
    initialize_repo exp_name.downcase
    push_to_remote exp_name
    push_to_remote exp_name

    start_id = create_repo("#{exp_name}_start")
    initialize_repo "#{exp_name.downcase}_start"
    push_to_remote "#{exp_name.downcase}_start"

    stop_id = create_repo("#{exp_name}_stop")
    initialize_repo "#{exp_name.downcase}_stop"
    push_to_remote "#{exp_name.downcase}_stop"

    return {:code => code_id, :config => config_id, :start_id => start_id, :stop_id => stop_id}
  end

  def initialize_repo(repo_name)
    Dir.chdir(Rails.root.join('ansible', 'roles'))
    Dir.mkdir(repo_name)
    FileUtils.cp_r 'sample/.', repo_name
  end

  def push_to_remote(repo_name)
    status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
      stdin.puts 'cd ' + Rails.root.join('ansible', 'roles', repo_name).to_s
      stdin.puts 'git init'
      stdin.puts 'git add .'
      stdin.puts 'git commit -am "first commit."'
      stdin.puts 'git remote add origin git@THUVMControl.cloudapp.net:Teacher_' + teacher + '/' + repo_name.downcase + '_config.git'
      stdin.puts 'git push -u origin master'
      stdin.close

      puts 'STDOUT:'
      puts stdout.read.strip
      puts 'STDERR:'
      puts stderr.read.strip
    end
  end
end
