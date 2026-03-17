module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_superadmin

    def index
      @users_count = User.count
      @shops_count = Shop.count
      @listings_count = Listing.count
    end

    private
    def require_superadmin
      redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.superadmin?
    end
  end
end
