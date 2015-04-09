class AddGitTokenToStudents < ActiveRecord::Migration
  def change
    add_column :students, :git_token, :string
  end
end
