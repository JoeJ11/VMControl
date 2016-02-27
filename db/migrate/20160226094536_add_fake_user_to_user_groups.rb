class AddFakeUserToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :fake_user, :integer
  end
end
