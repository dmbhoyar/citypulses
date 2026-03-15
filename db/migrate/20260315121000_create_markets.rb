class CreateMarkets < ActiveRecord::Migration[7.0]
  def change
    create_table :markets do |t|
      t.string :city, null: false
      t.float :latitude
      t.float :longitude
      t.decimal :rate, precision: 10, scale: 2

      t.timestamps
    end
  end
end
