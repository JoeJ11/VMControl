class CreateClusterConfigurations < ActiveRecord::Migration
  def change
    create_table :cluster_configurations do |t|
      t.string :specifier
      t.integer :size

      t.timestamps
    end
  end
end
