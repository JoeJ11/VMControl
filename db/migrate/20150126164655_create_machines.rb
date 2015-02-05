class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :ip_address
      t.string :setting
      t.integer :status
      t.references :student, index: true
    end
  end
end
