class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.text :description
      t.string :phone
      t.string :address
      t.references :user, foreign_key: true
      t.references :city, foreign_key: true
      t.string :template

      t.timestamps
    end
  end
end
