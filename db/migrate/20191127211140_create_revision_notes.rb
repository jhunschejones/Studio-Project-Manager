class CreateRevisionNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :revision_notes do |t|
      t.text :body
      t.boolean :is_user_editable
      t.boolean :is_completed
      t.string :track_version
      t.references :track, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
