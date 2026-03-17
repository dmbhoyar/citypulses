class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.string :subcategory
      t.decimal :price, precision: 12, scale: 2
      t.string :contact_number
      t.references :city, foreign_key: true
      t.references :user, foreign_key: true
      t.references :shop, foreign_key: true
      t.string :location
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
