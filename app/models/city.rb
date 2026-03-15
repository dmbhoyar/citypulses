class City < ApplicationRecord
  has_many :markets

  validates :name, presence: true, uniqueness: true
end
