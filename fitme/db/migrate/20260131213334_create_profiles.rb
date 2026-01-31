class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.float :height_cm
      t.float :weight_kg
      t.json :measurements
      t.string :avatar_3d_file_path
      t.boolean :is_public_api, default: true

      t.timestamps
    end
  end
end
