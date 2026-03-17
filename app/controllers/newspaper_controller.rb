class NewspaperController < ApplicationController
  def show
    @city = City.find_by(id: params[:city_id])
    @updates = if @city
      Update.where(city: @city).order(published_at: :desc).limit(50)
    else
      Update.order(published_at: :desc).limit(50)
    end
    respond_to do |format|
      format.html
    end
  end
end
