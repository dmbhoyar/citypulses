class AddRoleAndSubscriptionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, default: 'normal', null: false
    add_column :users, :subscription_expires_at, :datetime
    add_index :users, :role
  end
end
