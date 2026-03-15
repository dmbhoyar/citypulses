class Job < ApplicationRecord
  belongs_to :city
  validates :title, presence: true

  scope :search, ->(q) {
    return all unless q.present?
    where('title ILIKE :q OR description ILIKE :q OR category ILIKE :q', q: "%"+q+"%")
  }
end
