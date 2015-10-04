class Student < ActiveRecord::Base
  include GitToolkit

  has_one :machine

  # handle_asynchronously :setup_new_user, :priority => 100

  def self.setup(user_name, account_name)
    student = Student.find_by_mail_address user_name
    unless student
      student = Student.new
      student.setup_new_user(user_name, account_name)
    end
    return {
        :user_name => student.mail_address,
        :pub_key => student.public_key,
        :pri_key => student.private_key
    }
  end

  def setup_new_user(user_name, account_name)
    self.mail_address = user_name
    self.save

    self.generate_keys
    self.setup_git_server account_name
    self.save
  end

  def generate_keys
    key = SSHKey.generate(comment: self.mail_address)
    self.public_key = key.ssh_public_key
    self.private_key = key.private_key
  end

  def setup_git_server(account_name)
    self.create_git_user account_name, account_name
    self.add_ssh_key
  end

  def setup_repo(code_repo_id)
    self.get_token
    repo_id = self.fork_repo(code_repo_id)
    if repo_id != -1
      self.add_key_to_repo(repo_id, self.public_key)
      Student.publicize_repo repo_id
    end
    repo_id
    # This will set repo to be private, will cause trouble
    # self.edit_repo(repo_id)
  end

end
