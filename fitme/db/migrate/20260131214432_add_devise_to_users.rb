class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Remove has_secure_password column
    remove_column :users, :password_digest, :string if column_exists?(:users, :password_digest)

    # Add Devise columns
    add_column :users, :encrypted_password, :string, null: false, default: ""
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime

    add_index :users, :reset_password_token, unique: true
  end
end
