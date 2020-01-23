class CreateTrackVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :track_versions do |t|
      t.string :title, null: false
      t.integer :order, default: 0
      t.text :description
      t.references :track, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
