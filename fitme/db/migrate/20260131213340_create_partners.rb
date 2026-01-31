class CreatePartners < ActiveRecord::Migration[8.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :api_key
      t.string :webhook_url

      t.timestamps
    end
    add_index :partners, :api_key, unique: true
  end
end
