class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :xuetang_id
      t.string :mail_address
      t.string :public_key
    end
  end
end
