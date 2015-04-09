class Student < ActiveRecord::Base
  include GitToolkit

  has_one :machine

  def self.setup(user_name)
    student = Student.find_by_mail_address user_name
    if student
      return {
          :user_name => student.mail_address,
          :pub_key => student.public_key,
          :pri_key => student.private_key
      }
    else
      student = Student.new
      student.setup_new_user(user_name)
    end
  end

  def setup_new_user(user_name)
    self.mail_address = user_name
    self.save

    self.generate_keys
    self.setup_git_server
    self.setup_repo
    self.save
  end

  def generate_keys
    key = SSHKey.generate(comment: self.mail_address)
    self.public_key = key.ssh_public_key
    self.private_key = key.private_key
  end

  def setup_git_server
    self.create_git_user
    self.add_ssh_key
  end

  def setup_repo
    repo_id = self.create_repo('test')
    self.fork_repo(repo_id, 1)
  end
end
