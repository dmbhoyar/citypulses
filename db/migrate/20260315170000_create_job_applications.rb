class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications do |t|
      t.references :job, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.text :message
      t.string :resume_url

      t.timestamps
    end
  end
end
