class Student < ActiveRecord::Base
  include CloudToolkit

  has_one :machine

  def self.setup(user_name)
    student = Student.find_by_xuetang_id user_name
    if student
      return {
          :user_name => student.xuetang_id,
          :pub_key => student.public_key,
      }
    end
  end
end
