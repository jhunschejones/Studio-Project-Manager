class CreateTrackVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :track_versions do |t|
      t.string :name
      t.references :track, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
