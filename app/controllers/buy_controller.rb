class BuyController < ApplicationController
  def index
    @buys = Listing.where(category: 'sell').order(created_at: :desc)
  end
end
