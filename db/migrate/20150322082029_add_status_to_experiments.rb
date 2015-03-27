class AddStatusToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :status, :integer
  end
end
