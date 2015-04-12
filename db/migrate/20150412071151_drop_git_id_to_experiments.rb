class DropGitIdToExperiments < ActiveRecord::Migration
  def change
    remove_column :experiments, :git_id
  end
end
