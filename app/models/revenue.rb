class Revenue < ApplicationRecord
  belongs_to :shop
  validates :amount, numericality: true
end
