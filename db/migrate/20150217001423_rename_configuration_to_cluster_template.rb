class RenameConfigurationToClusterTemplate < ActiveRecord::Migration
  def change
    rename_table :configurations, :cluster_templates
  end
end
