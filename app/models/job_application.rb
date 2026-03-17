class JobApplication < ApplicationRecord
  belongs_to :job
  validates :name, :email, presence: true
end
