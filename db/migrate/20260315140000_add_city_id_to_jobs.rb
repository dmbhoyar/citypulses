class AddCityIdToJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :jobs, :city, foreign_key: true
  end
end