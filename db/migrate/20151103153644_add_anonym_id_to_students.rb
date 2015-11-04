class AddAnonymIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :anonym_id, :string
  end
end
