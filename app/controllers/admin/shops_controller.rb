module Admin
  class ShopsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_superadmin

    def index
      @shops = Shop.order(created_at: :desc)
    end

    def destroy
      s = Shop.find(params[:id])
      s.destroy
      redirect_to admin_shops_path, notice: 'Shop removed.'
    end

    private
    def require_superadmin
      redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.superadmin?
    end
  end
end
