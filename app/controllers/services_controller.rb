class ServicesController < ApplicationController
  def index
    @services = Listing.where(category: 'service').order(created_at: :desc)
  end
end
