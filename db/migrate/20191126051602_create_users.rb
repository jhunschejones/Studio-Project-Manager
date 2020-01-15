class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name_ciphertext, null: false
      t.string :email_ciphertext, null: false
      t.string :email_bidx, null: false

      t.timestamps
    end

    add_index :users, :email_bidx, unique: true
  end
end
