class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.references :experiment, index: true
      t.string :name
      t.string :git_token
      t.integer :git_id
      t.text :public_key
      t.text :private_key

      t.timestamps
    end
  end
end
