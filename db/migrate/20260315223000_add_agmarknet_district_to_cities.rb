class AddAgmarknetDistrictToCities < ActiveRecord::Migration[8.0]
  def change
    add_column :cities, :agmarknet_district, :string
    add_index :cities, :agmarknet_district
  end
end
