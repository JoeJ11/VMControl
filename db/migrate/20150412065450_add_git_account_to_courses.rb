class AddGitAccountToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :git_token, :string
    add_column :courses, :pub_key, :string
    add_column :courses, :mail_address, :string
  end
end
