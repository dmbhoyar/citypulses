class Market < ApplicationRecord
  belongs_to :city

  # simple haversine distance in km
  def self.haversine(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI/180
    rkm = 6371
    dlat_rad = (lat2-lat1) * rad_per_deg
    dlon_rad = (lon2-lon1) * rad_per_deg
    lat1_rad, lat2_rad = lat1 * rad_per_deg, lat2 * rad_per_deg

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    rkm * c
  end

  def self.nearby_rates(lat, lng, max_km = 50)
    return none unless lat && lng
    all.select do |m|
      next false unless m.latitude && m.longitude
      haversine(lat.to_f, lng.to_f, m.latitude.to_f, m.longitude.to_f) <= max_km
    end
  end
end
