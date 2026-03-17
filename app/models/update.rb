class Update < ApplicationRecord
  belongs_to :city, optional: true
  validates :title, presence: true
  
  # string-backed update types
  UPDATE_TYPES = %w[general offer event].freeze

  validates :update_type, inclusion: { in: UPDATE_TYPES }

  scope :offers, -> { where(update_type: 'offer') }
  scope :events, -> { where(update_type: 'event') }

  def offer?
    update_type == 'offer'
  end

  def event?
    update_type == 'event'
  end
end
