class RemoveClusterConfigurationIdFromMachine < ActiveRecord::Migration
  def change
    remove_column :machines, :cluster_configuration_id_id
  end
end
