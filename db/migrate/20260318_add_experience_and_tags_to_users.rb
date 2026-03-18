class AddExperienceAndTagsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :experience, :text
    add_column :users, :tags, :string
  end
end
