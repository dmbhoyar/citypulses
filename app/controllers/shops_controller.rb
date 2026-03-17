class ShopsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_shop, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @shops = Shop.order(created_at: :desc).page(params[:page]).per(20) rescue Shop.all
  end

  def show
  end

  def new
    @shop = current_user.shops.build
  end

  def create
    @shop = current_user.shops.build(shop_params)
    if @shop.save
      redirect_to @shop, notice: 'Shop created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @shop.update(shop_params)
      redirect_to @shop, notice: 'Shop updated.'
    else
      render :edit
    end
  end

  def destroy
    @shop.destroy
    redirect_to shops_path, notice: 'Shop removed.'
  end

  private
  def set_shop
    @shop = Shop.find(params[:id])
  end

  def authorize_owner!
    unless @shop.user == current_user || current_user.role == 'superadmin'
      redirect_to shops_path, alert: 'Not authorized'
    end
  end

  def shop_params
    params.require(:shop).permit(:name, :description, :phone, :address, :city_id, :template)
  end
end
