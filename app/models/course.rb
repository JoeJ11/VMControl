class Course < ActiveRecord::Base

  include GitToolkit

  def setup
    create_git_user("Teacher_#{self.teacher}", self.teacher)
    add_ssh_key
  end

  def setup_repo(exp_name)
    code_id = create_repo("#{exp_name}_code")
    config_id = fork_repo(1)
    change_name(config_id, "#{exp_name}_config")
    return {:code => code_id, :config => config_id}
  end

end
