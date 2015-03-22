class AddClusterConfigurationIndexToMachines < ActiveRecord::Migration
  def change
    add_reference :machines, :cluster_configuration_id, index: true
  end
end
