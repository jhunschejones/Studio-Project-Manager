class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.text :description
      t.string :upload_link
      t.datetime :archived_on
      t.boolean :is_archived, default: false

      t.timestamps
    end

    add_index(:projects, :title, where: "is_archived = false")
  end
end
