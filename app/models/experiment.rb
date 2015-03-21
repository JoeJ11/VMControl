class Experiment < ActiveRecord::Base
  belongs_to :cluster_configuration
  belongs_to :course
end
