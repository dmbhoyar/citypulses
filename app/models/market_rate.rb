class MarketRate < ApplicationRecord
  belongs_to :city, optional: true

  validates :commodity, presence: true
  validates :recorded_at, presence: true

  scope :for_city, ->(city) { where(city_id: city.id) if city }
  scope :for_commodity, ->(c) { where('commodity ILIKE ?', c.to_s) }
  scope :on_date, ->(d) { where(recorded_at: d) }

  def self.latest_for(city, commodity, date = Date.current)
    for_city(city).for_commodity(commodity).on_date(date).order(created_at: :desc).first
  end
end
