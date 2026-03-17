class CreateRevenues < ActiveRecord::Migration[8.0]
  def change
    create_table :revenues do |t|
      t.references :shop, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, default: 0
      t.string :source
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
