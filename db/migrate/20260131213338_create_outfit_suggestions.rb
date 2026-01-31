class CreateOutfitSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :outfit_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :suggested_for_date
      t.json :weather_snapshot
      t.json :item_ids
      t.boolean :selected, default: false

      t.timestamps
    end
  end
end
