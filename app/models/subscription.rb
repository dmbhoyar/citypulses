class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :shop, optional: true

  validates :status, presence: true

  def active?
    status == 'active' && expires_at.present? && expires_at > Time.current
  end
end
