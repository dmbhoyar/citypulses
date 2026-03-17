class ShopDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_shopowner

  def index
    @shop = current_user.shops.first
    @revenue_total = @shop ? @shop.revenues.sum(:amount) : 0
    @offers = Update.where(city: @shop&.city).offers if @shop
  end

  private
  def require_shopowner
    redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.shopowner?
  end
end
