class ChangeKeyField < ActiveRecord::Migration
  def change
    remove_column :courses, :pub_key
    add_column :courses, :pub_key, :text
    remove_column :students, :public_key
    add_column :students, :public_key, :text
    remove_column :students, :private_key
    add_column :students, :private_key, :text
    remove_column :machines, :setting
    add_column :machines, :setting, :text
  end
end
