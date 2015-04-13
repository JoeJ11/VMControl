class AddGitIdToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :git_id, :integer
  end
end
