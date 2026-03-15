class FarmingController < ApplicationController
  before_action :set_farming, only: [:show, :edit, :update, :destroy]

  def index
    @farmings = Farming.where(city_id: params[:city_id]).order(created_at: :desc)
  end

  def show
  end

  def new
    @farming = Farming.new
  end

  def create
    @farming = Farming.new(farming_params)
    if @farming.save
      redirect_to @farming, notice: 'Farming record created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @farming.update(farming_params)
      redirect_to @farming, notice: 'Farming record updated.'
    else
      render :edit
    end
  end

  def destroy
    @farming.destroy
    redirect_to farming_index_path, notice: 'Farming record removed.'
  end

  private
  def set_farming
    @farming = Farming.find(params[:id])
  end

  def farming_params
    params.require(:farming).permit(:title, :content, :city_id)
  end
end