class MyshopController < ApplicationController
  before_action :authenticate_user!
  before_action :require_shopowner

  def index
    @shop = current_user.shops.first
  end

  def configure
    @shop = current_user.shops.first || current_user.shops.build
    if request.patch? || request.put?
      if @shop.update(shop_params)
        redirect_to myshop_path, notice: 'Shop updated.'
      else
        render :configure
      end
    end
  end

  def workers
    @shop = current_user.shops.first
    @workers = @shop ? User.where(shop_id: @shop.id) : []
  end

  def subscribe
    @shop = current_user.shops.first
    unless @shop
      redirect_to myshop_path, alert: 'No shop found' and return
    end
    # placeholder subscription: set expiry one year from now
    current_user.update(subscription_expires_at: 1.year.from_now)
    redirect_to myshop_path, notice: 'Subscription activated for 1 year (demo)'
  end

  def offer_new
    @shop = current_user.shops.first
    @offer = Update.new
  end

  def offer_create
    @shop = current_user.shops.first
    @offer = Update.new(update_params)
    @offer.city = @shop.city if @shop&.city
    if @offer.save
      redirect_to myshop_path, notice: 'Offer added.'
    else
      render :offer_new
    end
  end

  def experience
    @shop = current_user.shops.first
    # Render a printable experience letter for the shop owner
    respond_to do |format|
      format.html
    end
  end

  def idcard
    @shop = current_user.shops.first
    respond_to do |format|
      format.html
    end
  end

  private
  def require_shopowner
    redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.shopowner?
  end

  def shop_params
    params.require(:shop).permit(:name, :description, :phone, :address, :template)
  end
end
