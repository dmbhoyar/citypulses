class FarmingController < ApplicationController
  before_action :set_farming, only: [:show]

  def index
    @farmings = if params[:city_id].present?
      Farming.where(city_id: params[:city_id]).order(created_at: :desc)
    else
      Farming.order(created_at: :desc)
    end
  end

  def show
  end

  def new
    authenticate_user!
    @farming = Farming.new
  end

  def create
    authenticate_user!
    @farming = Farming.new(farming_params)
    @farming.user = current_user if defined?(current_user)
    if @farming.save
      redirect_to farming_path(@farming), notice: 'Farming note created.'
    else
      render :new
    end
  end

  private
  def set_farming
    @farming = Farming.find(params[:id])
  end

  def farming_params
    params.require(:farming).permit(:title, :content, :city_id)
  end
end
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