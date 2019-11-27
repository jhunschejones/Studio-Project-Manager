class CreateDownloadLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :download_links do |t|
      t.string :title, null: false
      t.string :link, null: false
      t.references :track, null: true, foreign_key: true # download links can optionally belong to a track
      t.references :project, null: false, foreign_key: true # all download links belong to a project

      t.timestamps
    end
  end
end
