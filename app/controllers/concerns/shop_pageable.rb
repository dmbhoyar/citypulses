module ShopPageable
  extend ActiveSupport::Concern

  included do
    before_action :load_shop_for_page, only: [:configure, :index, :show]
  end

  def load_shop_for_page
    @shop = current_user.shops.first || current_user.shops.build(name: current_user.full_name + "'s Shop")
    @page_config = @shop.page_config || {}
  end

  def update_page_config_from_params
    return false unless params[:shop] && params[:shop][:page_config]
    cfg = params[:shop][:page_config]
    begin
      parsed = cfg.is_a?(String) ? JSON.parse(cfg) : cfg
    rescue
      parsed = {}
    end
    @shop.page_config = parsed
    @shop.save
  end
end
