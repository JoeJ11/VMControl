class UserGroup < ActiveRecord::Base
  include GitToolkit

  belongs_to :experiment
  has_and_belongs_to_many :students

end
