class Shop < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true
  has_many :listings, dependent: :destroy
  has_many :revenues, dependent: :destroy

  validates :name, presence: true

  after_initialize :ensure_page_config

  private
  def ensure_page_config
    self.page_config ||= {}
  end
end
