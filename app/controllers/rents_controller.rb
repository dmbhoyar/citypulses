class RentsController < ApplicationController
  before_action :set_rent, only: [:show, :edit, :update]

  def index
    @rents = Listing.where(category: 'rent').order(created_at: :desc)
  end

  def show
  end

  def new
    @rent = current_user ? current_user.listings.build(category: 'rent') : Listing.new(category: 'rent')
  end

  def create
    @rent = current_user ? current_user.listings.build(rent_params.merge(category: 'rent')) : Listing.new(rent_params.merge(category: 'rent'))
    if @rent.save
      redirect_to @rent, notice: 'Rent record created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @rent.update(rent_params)
      redirect_to @rent, notice: 'Rent record updated.'
    else
      render :edit
    end
  end

  private
  def set_rent
    @rent = Listing.find(params[:id])
  end

  def rent_params
    params.require(:listing).permit(:title, :description, :price, :contact_number, :city_id, :location)
  end
end
