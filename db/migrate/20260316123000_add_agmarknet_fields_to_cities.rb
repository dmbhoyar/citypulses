class AddAgmarknetFieldsToCities < ActiveRecord::Migration[8.1]
  def change
    add_column :cities, :agmarknet_state, :string
    add_column :cities, :agmarknet_market, :string
    add_index :cities, :agmarknet_state
    add_index :cities, :agmarknet_market
  end
end
