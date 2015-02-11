class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :tenant_id
      t.string :instance_id
      t.string :image_name

      t.timestamps
    end
  end
end
