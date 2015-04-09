class AddClusterConfigurationIndexToMachine < ActiveRecord::Migration
  def change
    add_reference :machines, :cluster_configuration, index: true
  end
end
