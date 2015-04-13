class ChangePubKeyInCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :pub_key
    add_column :courses, :public_key, :string
  end
end
