class CreateUserGroupsAndStudents < ActiveRecord::Migration
  def change
    create_table :user_groups_and_students, id: false do |t|
      t.belongs_to :user_group, index: true
      t.belongs_to :student, index:true
    end
  end
end
