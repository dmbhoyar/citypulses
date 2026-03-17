module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    # POST /webhooks/stripe
    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']

      event = nil

      if ENV['STRIPE_ENDPOINT_SECRET'].present?
        # verify signature using Stripe library
        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET'])
        rescue JSON::ParserError => e
          render plain: "Invalid payload", status: 400 and return
        rescue Stripe::SignatureVerificationError => e
          Rails.logger.warn "Stripe webhook signature verification failed: #{e.message}"
          render plain: "Invalid signature", status: 400 and return
        end
      else
        # Demo mode: allow webhook if demo env set or demo secret matches header
        if ENV['WEBHOOK_ALLOW_DEMO'] == '1' || (ENV['WEBHOOK_DEMO_SECRET'].present? && request.headers['X-DEMO-SIGNATURE'] == ENV['WEBHOOK_DEMO_SECRET'])
          begin
            event = JSON.parse(payload).with_indifferent_access
          rescue JSON::ParserError
            render plain: "Invalid payload", status: 400 and return
          end
        else
          render plain: "Webhooks not enabled", status: 403 and return
        end
      end

      # Normalize event object (when using Stripe library it's an object, else a hash)
      event_type = event[:type] || event['type']
      data_object = (event[:data] && event[:data][:object]) || (event['data'] && event['data']['object']) || event[:data]

      case event_type
      when 'checkout.session.completed'
        handle_checkout_completed(data_object)
      when 'invoice.payment_failed'
        handle_payment_failed(data_object)
      else
        Rails.logger.info "Unhandled stripe webhook event: #{event_type}"
      end

      render plain: 'ok'
    end

    private
    def handle_checkout_completed(obj)
      # obj may be a Hash (demo) or Stripe::Checkout::Session
      metadata = (obj.respond_to?(:metadata) ? obj.metadata : (obj['metadata'] || {}))
      sub_id = metadata['subscription_id']
      session_id = obj.respond_to?(:id) ? obj.id : obj['id']
      amount = (obj.respond_to?(:amount_total) ? obj.amount_total : obj['amount_total']).to_f / 100 rescue nil

      if sub_id.present?
        sub = Subscription.find_by(id: sub_id)
        if sub
          sub.update(status: 'active', provider_id: session_id, starts_at: Time.current, expires_at: 1.year.from_now)
          if sub.user
            sub.user.update(subscription_expires_at: sub.expires_at)
          end
          Rails.logger.info "Subscription #{sub.id} activated via webhook"
        else
          Rails.logger.warn "Subscription id #{sub_id} not found for webhook session"
        end
      else
        Rails.logger.warn "No subscription_id in webhook metadata"
      end
    end

    def handle_payment_failed(obj)
      # mark subscription as failed if possible
      metadata = (obj.respond_to?(:metadata) ? obj.metadata : (obj['metadata'] || {}))
      sub_id = metadata['subscription_id']
      if sub_id.present?
        sub = Subscription.find_by(id: sub_id)
        sub.update(status: 'past_due') if sub
      end
    end
  end
end
