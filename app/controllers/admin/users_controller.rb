module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_superadmin

    def index
      @users = User.order(created_at: :desc)
    end

    def destroy
      u = User.find(params[:id])
      u.destroy
      redirect_to admin_users_path, notice: 'User removed.'
    end

    private
    def require_superadmin
      redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.superadmin?
    end
  end
end
