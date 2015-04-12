class AddGitIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :git_id, :integer
  end
end
