class MyserviceController < ApplicationController
  include ShopPageable
  before_action :authenticate_user!
  before_action :require_service_provider

  def index
    # `load_shop_for_page` sets @shop and @page_config
  end

  def show
    # Render same view as index so `myservice_path` works
    render :index
  end

  def configure
    if request.patch? || request.put? || request.post?
      if update_page_config_from_params
        redirect_to myservice_path, notice: 'Service page saved.' and return
      else
        flash.now[:alert] = 'Unable to save page configuration'
      end
    end
  end

  def business_card
    @shop = current_user.shops.first || current_user.shops.build(name: "My Service")
    if request.patch? || request.put? || request.post?
      cfg = @shop.page_config || {}
      svc = params[:services_list] || ''
      cfg['services_list'] = svc.split(/\r?\n/).map(&:strip).reject(&:blank?)
      @shop.page_config = cfg
      if @shop.save
        redirect_to myservice_path, notice: 'Business card saved.'
      else
        flash.now[:alert] = 'Unable to save'
        render :business_card
      end
    end
  end

  private
  def require_service_provider
    redirect_to root_path, alert: 'Not authorized' unless current_user && current_user.role == 'service_provider'
  end
end
