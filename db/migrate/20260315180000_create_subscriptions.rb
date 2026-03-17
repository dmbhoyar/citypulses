class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true, null: false
      t.references :shop, foreign_key: true
      t.string :provider
      t.string :provider_id
      t.string :status, default: 'pending'
      t.datetime :starts_at
      t.datetime :expires_at
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
