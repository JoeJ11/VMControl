class ClusterConfiguration < ActiveRecord::Base
  has_many :cluster_templates
  include CloudToolkit
end
