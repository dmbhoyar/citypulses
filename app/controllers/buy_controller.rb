class BuyController < ApplicationController
  def index
    @buys = Buy.all
  end
end
