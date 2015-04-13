class ChangeGItIdInStudents < ActiveRecord::Migration
  def change
    remove_column :students, :git_id
    add_column :students, :git_id, :integer
  end
end
