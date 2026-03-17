class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @shop = current_user.shops.first
    unless @shop
      redirect_to myshop_path, alert: 'Create a shop first.' and return
    end
    @subscription = Subscription.new(user: current_user, shop: @shop)
  end

  def create
    @shop = current_user.shops.first
    unless @shop
      redirect_to myshop_path, alert: 'Create a shop first.' and return
    end

    # amount in rupees default demo 1000
    amount = params[:amount].to_f > 0 ? params[:amount].to_f : 1000

    # create a subscription record in pending state first
    sub = Subscription.create(user: current_user, shop: @shop, provider: (ENV['STRIPE_SECRET_KEY'].present? ? 'stripe' : 'local'), status: 'pending', amount: amount, starts_at: Time.current)

    if ENV['STRIPE_SECRET_KEY'].present?
      # create Stripe Checkout Session and include subscription id in metadata
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [{ price_data: { currency: 'inr', product_data: { name: "CityPulses Shop Subscription" }, unit_amount: (amount * 100).to_i }, quantity: 1 }],
        mode: 'payment',
        metadata: { subscription_id: sub.id },
        success_url: root_url + '?sub_success=1',
        cancel_url: root_url + '?sub_cancel=1'
      )
      redirect_to session.url, allow_other_host: true
    else
      # fallback/demo: activate subscription immediately
      sub.update(status: 'active', starts_at: Time.current, expires_at: 1.year.from_now)
      current_user.update(subscription_expires_at: sub.expires_at)
      redirect_to shop_dashboard_path, notice: 'Subscription activated (demo).'
    end
  end
end
