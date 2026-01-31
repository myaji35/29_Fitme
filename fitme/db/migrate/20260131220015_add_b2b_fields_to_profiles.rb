class AddB2bFieldsToProfiles < ActiveRecord::Migration[8.1]
  def change
    # Only add secure_id, other fields already exist
    add_column :profiles, :secure_id, :string
    add_index :profiles, :secure_id, unique: true
  end
end
