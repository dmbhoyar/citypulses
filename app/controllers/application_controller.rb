class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_locale
    if params[:locale].present?
      session[:locale] = params[:locale]
    end
    I18n.locale = session[:locale].presence || I18n.default_locale
  rescue => _
    I18n.locale = I18n.default_locale
  end

  # Keep locale in generated urls so navigation preserves language
  def default_url_options
    { locale: I18n.locale }
  end

    protected

    def configure_permitted_parameters
      if devise_controller?
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :mobile_number, :role])
        devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :mobile_number, :role])
      end
    end
end
