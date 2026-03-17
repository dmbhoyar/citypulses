class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @q = params[:q]
    @listings = Listing.where(status: 'active')
    @listings = @listings.where(city_id: params[:city_id]) if params[:city_id].present?
    @listings = @listings.where(category: params[:category]) if params[:category].present?
    @listings = @listings.order(created_at: :desc).page(params[:page]).per(20) rescue @listings
  end

  def show
  end

  def new
    @listing = current_user.listings.build
  end

  def create
    @listing = current_user.listings.build(listing_params)
    if @listing.save
      redirect_to @listing, notice: 'Listing created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: 'Listing updated.'
    else
      render :edit
    end
  end

  def destroy
    @listing.update(status: 'removed')
    redirect_to listings_path, notice: 'Listing removed.'
  end

  private
  def set_listing
    @listing = Listing.find(params[:id])
  end

  def authorize_owner!
    unless @listing.user == current_user || current_user.role == 'superadmin' || (current_user.role == 'shopowner' && @listing.shop&.user == current_user)
      redirect_to listings_path, alert: 'Not authorized'
    end
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :category, :subcategory, :price, :contact_number, :city_id, :shop_id, :location)
  end
end
