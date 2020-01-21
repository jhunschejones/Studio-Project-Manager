class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.string :title, null: false
      t.boolean :is_completed, default: false
      t.integer :order, default: 0
      t.string :versions, array: true, default: []
      t.references :project, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
