class HomeController < ApplicationController
  def index
    @cities = City.order(:name)

    @use_location = params[:use_location] == '1'
    @lat = params[:lat]
    @lng = params[:lng]

    if @use_location && @lat.present? && @lng.present?
      @nearby_markets = Market.nearby_rates(@lat, @lng, 50)
      @market_rate = @nearby_markets.first
      @city = @market_rate&.city_id && City.find_by(id: @market_rate.city_id)
      session[:city_id] = @city.id if @city
    else
      if params[:city_id].present?
        @city = City.find_by(id: params[:city_id])
        session[:city_id] = @city.id if @city
      elsif params[:city].present?
        @city = City.where('LOWER(name) = ?', params[:city].to_s.downcase).first
        session[:city_id] = @city.id if @city
      elsif session[:city_id].present?
        @city = City.find_by(id: session[:city_id])
      end

      if @city
        @market_rate = Market.where('LOWER(city) = ? OR city_id = ?', @city.name.to_s.downcase, @city.id)
                            .order(created_at: :desc).first
      else
        @market_rate = Market.order(created_at: :desc).first
      end
    end

    if @city
      @updates = Update.where(city: @city).order(created_at: :desc).limit(6)
      @jobs = Job.where(city: @city).order(created_at: :desc).limit(6)
      @farmings = Farming.where(city: @city).order(created_at: :desc).limit(6)
      @offers = Update.where(city: @city).offers.order(created_at: :desc).limit(4)
    else
      @updates = Update.order(created_at: :desc).limit(6)
      @jobs = Job.order(created_at: :desc).limit(6)
      @farmings = Farming.order(created_at: :desc).limit(6)
      @offers = Update.offers.order(created_at: :desc).limit(4)
    end

    today = Date.current
    yesterday = today - 1
    tomorrow = today + 1

    if @city
      require_dependency Rails.root.join('lib', 'agmarknet_client').to_s rescue nil
      require_dependency Rails.root.join('lib', 'weather_client').to_s rescue nil
      require_dependency Rails.root.join('lib', 'metals_client').to_s rescue nil
      require_dependency Rails.root.join('lib', 'news_client').to_s rescue nil

      district_query = @city.agmarknet_district.presence || @city.name

      state_name = @city.try(:agmarknet_state).presence || "Maharashtra"
      market_name = @market_rate.try(:city).presence || @city.try(:agmarknet_market).presence

      Rails.logger.info "[HomeController] Fetching market data for state=#{state_name} district=#{district_query}"

      client = AgmarknetClient.new

        # Set date range: match tested Postman request
        today = Date.current
        date_from = '2026-03-13'
        date_to = (today + 1).strftime('%Y-%m-%d')

        rows = client.fetch_market_data(
          state: state_name,
          district: district_query,
          date_from: date_from,
          date_to: date_to,
          sort: { 'Market' => 'desc' }
        ) rescue []

        # Fetch daily weather for city coordinates (if available)
        begin
          if @city.latitude.present? && @city.longitude.present?
            wclient = WeatherClient.new
            weather_start = Date.current.strftime('%Y-%m-%d')
            weather_end = (Date.current + 2).strftime('%Y-%m-%d')
            @weather = wclient.fetch_daily_weather(lat: @city.latitude, lon: @city.longitude, start_date: weather_start, end_date: weather_end)
            Rails.logger.info "[HomeController] Weather: fetched #{@weather[:days].size} day(s) for #{@city.name}"
          else
            @weather = { days: [] }
          end
        rescue => e
          Rails.logger.warn "[HomeController] Weather fetch failed: #{e.message}"
          @weather = { days: [] }
        end

        # Fetch city news (Google News RSS search)
        begin
          if @city && @city.name.present?
            nclient = NewsClient.new
            @city_news = nclient.fetch_city_news(@city.name, limit: 5)
          else
            @city_news = []
          end
        rescue => e
          Rails.logger.warn "[HomeController] News fetch failed: #{e.message}"
          @city_news = []
        end

      if rows.present?
        Rails.logger.info "[HomeController] API returned #{rows.size} records"

        # Market → Commodity grouping
        @market_rates = {}

        rows.each do |r|
          market = r['Market'].to_s.strip
          commodity = r['Commodity'].to_s.strip

          @market_rates[market] ||= {}
          @market_rates[market][commodity] ||= []

          @market_rates[market][commodity] << {
            variety: r['Variety'],
            grade: r['Grade'],
            min_price: r['Min_Price'],
            max_price: r['Max_Price'],
            modal_price: r['Modal_Price'],
            date: r['Arrival_Date']
          }
        end

        # For compatibility if views expect these
        @rates_today = rows.select { |r| r[:date] == today }
        @rates_yesterday = rows.select { |r| r[:date] == yesterday }
        @rates_tomorrow = rows.select { |r| r[:date] == tomorrow }

      else
        Rails.logger.info "[HomeController] API returned no rows, using DB fallback"

        base = Market.where(city_id: @city.id)

        @rates_today = base.where(price_date: today)
        @rates_yesterday = base.where(price_date: yesterday)
        @rates_tomorrow = base.where(price_date: tomorrow)

        @market_rates = {}
      end
    else
      base = Market.all

      @rates_today = base.where(price_date: today)
      @rates_yesterday = base.where(price_date: yesterday)
      @rates_tomorrow = base.where(price_date: tomorrow)

      @market_rates = {}
    end

    # Fetch live metals INR/gram using MetalsClient
    begin
      mclient = MetalsClient.new
      metals_inr = mclient.fetch_inr_per_gram
      # metals_inr may include _meta with usd->inr info
      @metals = { gold: metals_inr['gold'], silver: metals_inr['silver'] }
      @metals_meta = metals_inr['_meta'] || {}
      Rails.logger.info "[HomeController] Metals (INR/g) fetched: #{@metals.inspect} meta=#{@metals_meta.inspect}"
    rescue => e
      Rails.logger.warn "[HomeController] Metals fetch failed: #{e.message}"
      @metals = { gold: nil, silver: nil }
      @metals_meta = {}
    end

    # Compute karat prices from 24K (if available)
    if @metals[:gold].present?
      gold_24 = @metals[:gold].to_f
      # spot values (per gram)
      @gold_24_per_g = gold_24.round(0)
      gold_22_f = (gold_24 * (22.0/24.0))
      gold_18_f = (gold_24 * (18.0/24.0))
      @gold_22_per_g = gold_22_f.round(0)
      @gold_18_per_g = gold_18_f.round(0)

      # Improved real-world retail formula
      # Configurable ENV values (defaults shown):
      # METALS_WASTAGE_PERCENT (default 0.5) - manufacturing wastage added to metal value
      # METALS_MAKING_TYPE ('fixed'|'percent') default 'fixed'
      # METALS_MAKING_PER_10G (fixed making ₹ per 10g) default 800
      # METALS_MAKING_PERCENT (making as percent of metal value) default 2.0
      # METALS_DEALER_PREMIUM_PERCENT default 0.0
      # METALS_GST_PERCENT default 3.0
      # METALS_ROUND_NEAREST default 10 (round final to nearest 10)

      wastage_pct = (ENV['METALS_WASTAGE_PERCENT'] || '0.5').to_f
      making_type = (ENV['METALS_MAKING_TYPE'] || 'fixed')
      making_per_10g = (ENV['METALS_MAKING_PER_10G'] || '800').to_f
      making_percent = (ENV['METALS_MAKING_PERCENT'] || '2.0').to_f
      dealer_premium_pct = (ENV['METALS_DEALER_PREMIUM_PERCENT'] || '0').to_f
      gst_pct = (ENV['METALS_GST_PERCENT'] || '3.0').to_f
      round_nearest = (ENV['METALS_ROUND_NEAREST'] || '10').to_i

      # helper to apply rounding
      round_final = ->(val) do
        return nil unless val
        rn = round_nearest > 0 ? round_nearest : 1
        ((val / rn).round * rn).to_i
      end

      # compute per-karat retail using a standard sequence
      compute_retail = ->(spot_per_g, karat) do
        purity_ratio = karat.to_f / 24.0
        metal_value_per_10g = spot_per_g * purity_ratio * 10.0
        metal_after_wastage = metal_value_per_10g * (1.0 + wastage_pct / 100.0)

        making_charge = if making_type == 'percent'
                          metal_after_wastage * (making_percent / 100.0)
                        else
                          making_per_10g
                        end

        premium = (metal_after_wastage + making_charge) * (dealer_premium_pct / 100.0)

        taxable_value = metal_after_wastage + making_charge + premium
        gst = taxable_value * (gst_pct / 100.0)
        final = taxable_value + gst

        {
          spot_per_10g: metal_value_per_10g.round(0),
          metal_after_wastage: metal_after_wastage.round(0),
          making_charge: making_charge.round(0),
          premium: premium.round(0),
          taxable_value: taxable_value.round(0),
          gst: gst.round(0),
          final_retail: round_final.call(final)
        }
      end

      # 24K
      gold24 = compute_retail.call(gold_24, 24)
      @gold_24_per_10g_spot = gold24[:spot_per_10g]
      @gold_24_per_10g_retail = gold24[:final_retail]
      @gold_24_breakdown = gold24

      # 22K
      gold22 = compute_retail.call(gold_22_f, 22)
      @gold_22_per_10g_spot = gold22[:spot_per_10g]
      @gold_22_per_10g_retail = gold22[:final_retail]
      @gold_22_breakdown = gold22

      # 18K
      gold18 = compute_retail.call(gold_18_f, 18)
      @gold_18_per_10g_spot = gold18[:spot_per_10g]
      @gold_18_per_10g_retail = gold18[:final_retail]
      @gold_18_breakdown = gold18
    else
      @gold_24_per_g = @gold_22_per_g = @gold_18_per_g = nil
    end

    # Silver retail calculations
    if @metals[:silver].present?
      silver_g = @metals[:silver].to_f
      s_markup_pct = (ENV['METALS_MARKUP_PERCENT'] || '0').to_f
      s_making_per_10g = (ENV['METALS_MAKING_PER_10G'] || '0').to_f
      s_tax_pct = (ENV['METALS_TAX_PERCENT'] || '0').to_f

      silver_spot_per_10g = silver_g * 10.0
      silver_pre_tax = silver_spot_per_10g * (1.0 + s_markup_pct / 100.0) + s_making_per_10g
      silver_tax = silver_pre_tax * (s_tax_pct / 100.0)
      @silver_per_10g_retail = (silver_pre_tax + silver_tax).round(0)
      @silver_per_10g_spot = silver_spot_per_10g.round(0)
      @silver_per_kg_retail = (@silver_per_10g_retail * 100).round(0)
      @silver_per_kg_spot = (silver_g * 1000.0).round(0)
    else
      @silver_per_10g_retail = @silver_per_10g_spot = @silver_per_kg_retail = @silver_per_kg_spot = nil
    end

    @rates_today ||= []
    @rates_yesterday ||= []
    @rates_tomorrow ||= []
  end

  def set_city
    city = City.find_by(id: params[:city_id])
    if city
      session[:city_id] = city.id
      flash[:notice] = "City set to #{city.name}"
    else
      flash[:alert] = 'City not found'
    end
    redirect_to root_path
  end
end
