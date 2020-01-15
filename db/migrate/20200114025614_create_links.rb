class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.string :text, null: false
      t.string :url, null: false
      t.string :link_for_class, null: false
      t.integer :link_for_id, null: false
      t.references :user, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
