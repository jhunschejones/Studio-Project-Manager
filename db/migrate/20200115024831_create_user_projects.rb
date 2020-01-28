class CreateUserProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :user_projects do |t|
      t.references :project, null: false, foreign_key: {on_delete: :cascade}
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :project_role, default: "project_user"
      t.boolean :receive_notifications, default: true

      t.timestamps
    end

    add_index :user_projects, [:project_id, :user_id], unique: true
  end
end
