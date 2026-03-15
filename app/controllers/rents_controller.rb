class RentsController < ApplicationController
  def index
    @rents = Rent.all
  end

  def show
    @rent = Rent.find(params[:id])
  end

  def new
    @rent = Rent.new
  end

  def create
    @rent = Rent.new(rent_params)
    if @rent.save
      redirect_to @rent, notice: 'Rent record created.'
    else
      render :new
    end
  end

  def edit
    @rent = Rent.find(params[:id])
  end

  def update
    @rent = Rent.find(params[:id])
    if @rent.update(rent_params)
      redirect_to @rent, notice: 'Rent record updated.'
    else
      render :edit
    end
  end
end
