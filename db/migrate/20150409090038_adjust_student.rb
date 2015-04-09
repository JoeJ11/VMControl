class AdjustStudent < ActiveRecord::Migration
  def change
    remove_column :students, :xuetang_id
    add_column :students, :private_key, :string
  end
end
