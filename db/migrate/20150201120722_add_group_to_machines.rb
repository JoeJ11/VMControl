class AddGroupToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :group, :string
  end
end
