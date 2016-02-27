class RenameCorrelationTable < ActiveRecord::Migration
  def change
    rename_table :user_groups_and_students, :students_user_groups
  end
end
