class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.references :cluster_configuration, index: true
      t.references :course, index: true

      t.timestamps
    end
  end
end
