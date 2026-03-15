class AddCityIdToMarkets < ActiveRecord::Migration[7.0]
  def change
    add_reference :markets, :city, foreign_key: true
  end
end