class AddDistrictToMarkets < ActiveRecord::Migration[7.0]
  def change
    add_column :markets, :district, :string
    add_index :markets, :district
  end
end
