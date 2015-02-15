class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :name
      t.string :image_id
      t.string :flavor_id
      t.string :internal_ip
      t.string :external_ip
      t.boolean :ext_enable
      t.string :config_id

      t.timestamps
    end
  end
end
