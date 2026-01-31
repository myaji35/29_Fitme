class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :color
      t.string :season
      t.json :meta_data

      t.timestamps
    end
  end
end
