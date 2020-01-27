class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :action
      t.text :description
      t.references :notifiable, polymorphic: true
      t.references :project, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
