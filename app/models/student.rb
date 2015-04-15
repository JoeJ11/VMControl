class Student < ActiveRecord::Base
  include GitToolkit

  has_one :machine

  def self.setup(user_name)
    student = Student.find_by_mail_address user_name
    unless student
      student = Student.new
      student.setup_new_user(user_name)
      return {
          :user_name => student.mail_address,
          :pub_key => StringIO.new(student.public_key),
          :pri_key => StringIO.new(student.private_key)
      }
    end
    return student
  end

  def setup_new_user(user_name)
    self.mail_address = user_name
    self.save

    self.generate_keys
    self.setup_git_server
    self.save
  end

  def generate_keys
    key = SSHKey.generate(comment: self.mail_address)
    self.public_key = key.ssh_public_key
    self.private_key = key.private_key
  end

  def setup_git_server
    self.create_git_user("User_#{id.to_s}", "Unknown_#{id.to_s}")
    self.add_ssh_key
  end

  def setup_repo(exp_id)
    self.get_token
    exp = Experiment.find exp_id
    repo_id = self.fork_repo(exp.code_repo_id) if exp
    self.edit_repo(repo_id)
  end
end
