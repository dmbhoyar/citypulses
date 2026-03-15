class HomeController < ApplicationController
  def index
    # load available cities for selector
    @cities = City.order(:name)

    # allow selection by city_id param, session, or plain name, or by geolocation
    @use_location = params[:use_location] == '1'
    @lat = params[:lat]
    @lng = params[:lng]

    if @use_location && @lat.present? && @lng.present?
      @nearby_markets = Market.nearby_rates(@lat, @lng, 50)
      @market_rate = @nearby_markets.first
      @city = @nearby_markets.first&.city_id && City.find_by(id: @nearby_markets.first.city_id)
    else
      if params[:city_id].present?
        @city = City.find_by(id: params[:city_id])
        session[:city_id] = @city.id if @city
      elsif session[:city_id].present?
        @city = City.find_by(id: session[:city_id])
      elsif params[:city].present?
        @city = City.where('name ILIKE ?', params[:city]).first
      end

      if @city
        @market_rate = Market.where('city ILIKE ? OR city_id = ?', @city.name, @city.id).order(created_at: :desc).first
      else
        @market_rate = Market.order(created_at: :desc).first
      end
    end

    # load related content scoped to selected city when available
    if @city
      @updates = Update.where(city: @city).order(created_at: :desc).limit(6)
      @jobs = Job.where(city: @city).order(created_at: :desc).limit(6)
      @farmings = Farming.where(city: @city).order(created_at: :desc).limit(6)
      @offers = Update.where(city: @city).where('title ILIKE ?', '%offer%').order(created_at: :desc).limit(4)
    else
      @updates = Update.order(created_at: :desc).limit(6)
      @jobs = Job.order(created_at: :desc).limit(6)
      @farmings = Farming.order(created_at: :desc).limit(6)
      @offers = Update.where('title ILIKE ?', '%offer%').order(created_at: :desc).limit(4)
    end
  end

  def set_city
    city = City.find_by(id: params[:city_id])
    if city
      session[:city_id] = city.id
      flash[:notice] = "City set to #{city.name}"
    else
      flash[:alert] = 'City not found'
    end
    redirect_to root_path
  end
end
