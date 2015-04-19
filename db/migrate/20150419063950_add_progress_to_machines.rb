class AddProgressToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :progress, :integer
    add_column :machines, :url, :string
  end
end
