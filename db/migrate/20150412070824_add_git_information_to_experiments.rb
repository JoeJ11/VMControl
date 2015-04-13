class AddGitInformationToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :code_repo_id, :integer
    add_column :experiments, :config_repo_id, :integer
  end
end
