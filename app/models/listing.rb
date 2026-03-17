class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true
  belongs_to :shop, optional: true

  CATEGORY_TYPES = %w[sell rent service vehicle land].freeze

  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORY_TYPES }
end
