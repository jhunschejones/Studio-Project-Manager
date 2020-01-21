class CreateRevisionNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :revision_notes do |t|
      t.text :body
      t.boolean :is_user_editable
      t.boolean :is_completed
      t.references :track_version, null: false, foreign_key: {on_delete: :cascade}
      t.references :user, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
