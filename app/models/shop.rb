class Shop < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true
  has_many :listings, dependent: :destroy
  has_many :revenues, dependent: :destroy

  validates :name, presence: true
end
