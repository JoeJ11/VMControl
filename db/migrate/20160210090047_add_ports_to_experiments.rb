class AddPortsToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :port, :string
  end
end
