class AddDeleteMachineToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :delete_machine, :bool, :default => true
  end
end
