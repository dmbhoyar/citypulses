class CreateUpdates < ActiveRecord::Migration[7.0]
  def change
    create_table :updates do |t|
      t.string :title, null: false
      t.text :content
      t.references :city, foreign_key: true
      t.timestamps
    end
  end
end