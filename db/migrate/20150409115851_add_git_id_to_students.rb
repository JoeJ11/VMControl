class AddGitIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :git_id, :string
  end
end
