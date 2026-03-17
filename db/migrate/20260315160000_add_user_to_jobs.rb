class AddUserToJobs < ActiveRecord::Migration[8.0]
  def change
    add_reference :jobs, :user, foreign_key: true
  end
end
