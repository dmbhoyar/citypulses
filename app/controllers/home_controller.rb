class HomeController < ApplicationController
  def index
    # city selection or lat/lng
    @city = params[:city]
    @use_location = params[:use_location] == '1'
    @lat = params[:lat]
    @lng = params[:lng]

    if @use_location && @lat.present? && @lng.present?
      @nearby_markets = Market.nearby_rates(@lat, @lng, 50)
      @market_rate = @nearby_markets.first
    elsif @city.present?
      # if a City record exists, prefer markets that match that city name
      city_record = City.where('name ILIKE ?', @city).first
      if city_record
        @market_rate = Market.where('city ILIKE ?', city_record.name).order(created_at: :desc).first
      else
        @market_rate = Market.where('city ILIKE ?', @city).order(created_at: :desc).first
      end
    else
      @market_rate = Market.order(created_at: :desc).first
    end
  end
end
