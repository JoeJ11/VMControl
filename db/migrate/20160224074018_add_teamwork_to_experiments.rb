class AddTeamworkToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :teamwork, :boolean, :default => false
  end
end
