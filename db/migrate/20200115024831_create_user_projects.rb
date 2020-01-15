class CreateUserProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :user_projects do |t|
      t.references :project, null: false, foreign_key: {on_delete: :cascade}
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :role, default: "user"

      t.timestamps
    end
  end
end
