class Job < ApplicationRecord
  belongs_to :city
  belongs_to :user, optional: true
  validates :title, presence: true

  scope :search, ->(q) {
    return all unless q.present?
    where('LOWER(title) LIKE :q OR LOWER(description) LIKE :q OR LOWER(category) LIKE :q', q: "%"+q.to_s.downcase+"%")
  }
end
