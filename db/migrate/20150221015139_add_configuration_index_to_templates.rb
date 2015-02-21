class AddConfigurationIndexToTemplates < ActiveRecord::Migration
  def change
    add_reference :cluster_templates, :cluster_configuration, index: true
  end
end
