class AddInstantiatedToClusterConfigurations < ActiveRecord::Migration
  def change
    add_column :cluster_configurations, :instantiated, :string
  end
end
