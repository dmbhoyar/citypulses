class UpdatesController < ApplicationController
  before_action :set_update, only: [:show, :edit, :update, :destroy]

  def index
    @updates = Update.where(city_id: params[:city_id]).order(created_at: :desc)
  end

  def show
  end

  def new
    @update = Update.new
  end

  def create
    @update = Update.new(update_params)
    if @update.save
      redirect_to @update, notice: 'Update created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @update.update(update_params)
      redirect_to @update, notice: 'Update updated.'
    else
      render :edit
    end
  end

  def destroy
    @update.destroy
    redirect_to updates_path, notice: 'Update removed.'
  end

  private
  def set_update
    @update = Update.find(params[:id])
  end

  def update_params
    params.require(:update).permit(:title, :content, :city_id)
  end
end