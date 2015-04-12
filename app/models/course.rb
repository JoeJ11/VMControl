class Course < ActiveRecord::Base

  include GitToolkit

  def setup
    create_git_user("Teacher_#{self.teacher}", self.teacher)
  end

end
