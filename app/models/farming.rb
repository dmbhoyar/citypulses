class Farming < ApplicationRecord
  belongs_to :city, optional: true
  validates :title, presence: true
end
