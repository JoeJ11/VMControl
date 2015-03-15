class AddUserNameToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :user_name, :string
  end
end
