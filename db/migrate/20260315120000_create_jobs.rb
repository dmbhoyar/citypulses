class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.string :company
      t.string :location
      t.string :external_url

      t.timestamps
    end
  end
end
