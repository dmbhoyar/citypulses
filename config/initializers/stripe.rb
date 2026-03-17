if ENV['STRIPE_SECRET_KEY'].present?
  require 'stripe'
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
end
