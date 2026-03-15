class CreateFarmings < ActiveRecord::Migration[7.0]
  def change
    create_table :farmings do |t|
      t.string :title, null: false
      t.text :content
      t.references :city, foreign_key: true
      t.timestamps
    end
  end
end