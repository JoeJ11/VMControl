class AddSlavesToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :slaves, :string
  end
end
