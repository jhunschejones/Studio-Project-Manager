class CreateUsersProjectsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :projects do |t|
      t.index :user_id
      t.index :project_id
    end
  end
end
