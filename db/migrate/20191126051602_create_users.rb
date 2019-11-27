class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, default: "user"
      t.string :password_digest, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.string :email_verification_token
      t.datetime :email_verification_sent_at
      t.string :unconfirmed_email
      t.boolean :is_verified, default: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
