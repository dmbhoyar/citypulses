class MyshopController < ApplicationController
  include ShopPageable
  before_action :authenticate_user!
  before_action :require_shopowner

  def index
    @shop = current_user.shops.first
  end

  def show
    # For resource :myshop (myshop_path) render the same as index
    @shop = current_user.shops.first
    render :index
  end

  def configure
    # @shop loaded by ShopPageable
    if request.patch? || request.put?
      saved = true
      # update normal shop fields
      saved = saved && @shop.update(shop_params)
      # update page_config JSON if present
      saved = saved && update_page_config_from_params
      if saved
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

  def create_worker
    @shop = current_user.shops.first
    unless @shop
      redirect_to myshop_path, alert: 'No shop found' and return
    end

    # Build a new worker user. We generate a random password and mark role as shopworker.
    attrs = params.require(:worker).permit(:first_name, :last_name, :email, :mobile_number)
    password = Devise.friendly_token.first(10)
    user = User.new(attrs.merge(password: password, password_confirmation: password, role: 'shopworker', shop_id: @shop.id))
    if user.save
      # Optionally send reset password instructions so worker can set their password.
      user.send_reset_password_instructions
      redirect_to workers_myshop_path, notice: "Worker created — an email was sent to set password."
    else
      @workers = User.where(shop_id: @shop.id)
      flash.now[:alert] = 'Unable to create worker: ' + user.errors.full_messages.join(', ')
      render :workers
    end
  end

  def update_worker
    @shop = current_user.shops.first
    unless @shop
      redirect_to myshop_path, alert: 'No shop found' and return
    end
    worker_id = params[:worker] && params[:worker][:id]
    @worker = User.find_by(id: worker_id, shop_id: @shop.id)
    unless @worker
      redirect_to workers_myshop_path, alert: 'Worker not found' and return
    end
    attrs = params.require(:worker).permit(:first_name, :last_name, :mobile_number, :experience, :tags)
    if @worker.update(attrs)
      redirect_to workers_myshop_path, notice: 'Worker updated.'
    else
      @workers = User.where(shop_id: @shop.id)
      flash.now[:alert] = 'Unable to update worker: ' + @worker.errors.full_messages.join(', ')
      render :workers
    end
  end

  def worker_experience
    @shop = current_user.shops.first
    @worker = User.find_by(id: params[:id], shop_id: @shop.id)
    unless @worker
      redirect_to workers_myshop_path, alert: 'Worker not found' and return
    end
    respond_to do |format|
      format.html
    end
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
