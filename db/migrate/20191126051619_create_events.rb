class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :scheduled_for, null: false
      t.datetime :completed_on
      t.references :project, null: false, foreign_key: {on_delete: :cascade}
      t.references :user, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
