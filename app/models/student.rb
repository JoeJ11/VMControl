class Student < ActiveRecord::Base
  include CloudToolkit

  has_one :machine

  def self.setup(user_name)
    student = Student.find_by_mail_address user_name
    if student
      return {
          :user_name => student.mail_address,
          :pub_key => student.public_key,
          :pri_key => student.private_key
      }
    end
  end
end
