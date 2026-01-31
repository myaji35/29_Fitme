class UpdatePartnersForSubscription < ActiveRecord::Migration[8.1]
  def change
    add_column :partners, :company_name, :string
    add_column :partners, :contact_email, :string
    add_column :partners, :website_url, :string
    add_column :partners, :subscription_status, :string, default: "trial", null: false
    add_column :partners, :subscription_started_at, :datetime
    add_column :partners, :subscription_ends_at, :datetime
    add_column :partners, :monthly_fee, :decimal, precision: 10, scale: 2, default: 50
    add_column :partners, :api_calls_count, :integer, default: 0
    add_column :partners, :last_billed_at, :datetime

    add_index :partners, :subscription_status
  end
end
