class AddFieldsForAgmarknetAndNews < ActiveRecord::Migration[8.0]
  def change
    change_table :markets, bulk: true do |t|
      t.string :commodity
      t.decimal :min_price, precision: 12, scale: 2
      t.decimal :max_price, precision: 12, scale: 2
      t.decimal :modal_price, precision: 12, scale: 2
      t.date :price_date
      t.string :source_url
    end

    change_table :updates, bulk: true do |t|
      t.string :source_url
      t.datetime :published_at
    end
  end
end
