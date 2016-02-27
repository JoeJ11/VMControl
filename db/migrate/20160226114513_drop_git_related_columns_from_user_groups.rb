class DropGitRelatedColumnsFromUserGroups < ActiveRecord::Migration
  def change
    remove_column :user_groups, :git_id
    remove_column :user_groups, :git_token
    remove_column :user_groups, :public_key
    remove_column :user_groups, :private_key
  end
end
