class ChangePublicKeyFiled < ActiveRecord::Migration
  def change
    remove_column :courses, :pub_key
    remove_column :courses, :public_key
    add_column :courses, :public_key, :text
  end
end
