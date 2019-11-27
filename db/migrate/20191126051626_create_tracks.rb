class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.string :title, null: false
      t.boolean :is_completed, default: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
