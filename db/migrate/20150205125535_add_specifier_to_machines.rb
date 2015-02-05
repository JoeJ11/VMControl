class AddSpecifierToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :specifier, :string
  end
end
