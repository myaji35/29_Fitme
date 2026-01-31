class CreateApiUsageLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :api_usage_logs do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.string :request_type
      t.integer :cost, default: 250

      t.timestamps
    end
  end
end
