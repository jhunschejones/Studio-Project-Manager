class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :title
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.references :commentable, polymorphic: true

      t.timestamps
    end
  end
end
