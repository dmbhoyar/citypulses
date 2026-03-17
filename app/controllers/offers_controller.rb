class OffersController < ApplicationController
  def index
    # Use global city selection (session[:city_id]) rather than a local selector.
    @city = session[:city_id].present? ? City.find_by(id: session[:city_id]) : nil

    # Today's date for header
    @today = Date.current

    # Offers and events using dedicated update_type when available
    if @city
      @offers = Update.where(city: @city).offers.order(created_at: :desc)
      @events = Update.where(city: @city).events.where("DATE(created_at) = ?", @today).order(created_at: :desc)
    else
      @offers = Update.offers.order(created_at: :desc)
      @events = Update.events.where("DATE(created_at) = ?", @today).order(created_at: :desc)
    end
  end
end
