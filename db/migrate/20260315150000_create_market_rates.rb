class CreateMarketRates < ActiveRecord::Migration[8.0]
  def change
    create_table :market_rates do |t|
      t.bigint :city_id, index: true
      t.string :commodity
      t.decimal :rate, precision: 12, scale: 2
      t.date :recorded_at
      t.float :latitude
      t.float :longitude
      t.string :source

      t.timestamps
    end
    add_foreign_key :market_rates, :cities
    add_index :market_rates, [:city_id, :commodity, :recorded_at], name: 'index_market_rates_on_city_commodity_date'
  end
end
