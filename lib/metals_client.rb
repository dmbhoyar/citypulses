require 'open-uri'
require 'json'

# Metals client using gold-api.com for metal prices and exchangerate.host for USD→INR
# Requires optional ENV['GOLD_API_KEY'] for gold-api; exchangerate.host is free.
class MetalsClient
  GOLD_API_BASE = 'https://api.gold-api.com/price'
  EXCHANGE_API = 'https://api.exchangerate.host/latest'
  OUNCE_TO_GRAM = 31.1034768

  # Returns a hash with INR-per-gram values, e.g. { 'gold' => 5200.12, 'silver' => 65.23 }
  def fetch_inr_per_gram
    cache_key = 'metals_inr_per_g'

    # Prefer a cached value only if it contains a valid usd_to_inr meta value
    # and also has numeric metal prices. If the cached entry lacks numeric
    # values (nil), refresh the cache by computing fresh values.
    cached = Rails.cache.read(cache_key) rescue nil
    if cached.is_a?(Hash) && cached['_meta'] && cached['_meta']['usd_to_inr'].present? && cached['gold'].present? && cached['silver'].present?
      Rails.logger.info "MetalsClient: using cached metals_inr_per_g (source=#{cached['_meta']['source']} usd_to_inr=#{cached['_meta']['usd_to_inr']})"
      return cached
    end

    # Compute fresh value and write to cache
    # Allow overriding USD->INR via ENV for exact matching
    env_override = ENV['METALS_USD_TO_INR']
    usd_to_inr = env_override.present? ? env_override.to_f : fetch_usd_to_inr
    usd_to_inr_used = usd_to_inr
    source = env_override.present? ? 'env_override' : 'auto'

      # If external exchange lookup failed, allow a fallback ENV or safe default
      if usd_to_inr_used.nil?
        fallback_env = ENV['METALS_FALLBACK_USD_TO_INR']
        if fallback_env.present?
          usd_to_inr_used = fallback_env.to_f
          source = 'fallback_env'
          Rails.logger.warn "MetalsClient: using fallback ENV METALS_FALLBACK_USD_TO_INR=#{fallback_env}"
        else
          # Tunable default — set conservatively; can be overridden via ENV
          default_rate = (ENV['METALS_DEFAULT_USD_TO_INR'] || '82.0').to_f
          usd_to_inr_used = default_rate
          source = 'default'
          Rails.logger.warn "MetalsClient: exchangerate lookup failed; using default usd_to_inr=#{usd_to_inr_used}"
        end
      end

      result = {}
      # Allow direct ENV overrides for raw per-gram values or USD/oz values
      env_gold_per_g = ENV['METALS_GOLD_PER_G']
      env_silver_per_g = ENV['METALS_SILVER_PER_G']
      env_gold_usd_oz = ENV['METALS_GOLD_USD_OZ']
      env_silver_usd_oz = ENV['METALS_SILVER_USD_OZ']

      alt_prices = nil
      { 'XAU' => 'gold', 'XAG' => 'silver' }.each do |symbol, key|
        # 1) direct per-gram override
        if key == 'gold' && env_gold_per_g.present?
          result[key] = env_gold_per_g.to_f.round(2)
          Rails.logger.info "MetalsClient: used ENV METALS_GOLD_PER_G=#{env_gold_per_g}"
          next
        elsif key == 'silver' && env_silver_per_g.present?
          result[key] = env_silver_per_g.to_f.round(2)
          Rails.logger.info "MetalsClient: used ENV METALS_SILVER_PER_G=#{env_silver_per_g}"
          next
        end

        # 2) USD/oz override
        if key == 'gold' && env_gold_usd_oz.present?
          price_usd_oz = env_gold_usd_oz.to_f
          Rails.logger.info "MetalsClient: used ENV METALS_GOLD_USD_OZ=#{env_gold_usd_oz}"
        elsif key == 'silver' && env_silver_usd_oz.present?
          price_usd_oz = env_silver_usd_oz.to_f
          Rails.logger.info "MetalsClient: used ENV METALS_SILVER_USD_OZ=#{env_silver_usd_oz}"
        else
          # 3) primary API
          price_usd_oz = fetch_price_from_gold_api(symbol)
          # 4) fallback public API (data-asg.goldprice.org)
          if price_usd_oz.nil?
            alt_prices ||= fetch_alt_goldprice
            if alt_prices
              price_usd_oz = (symbol == 'XAU' ? alt_prices[:xau] : alt_prices[:xag])
              Rails.logger.info "MetalsClient: fallback alt price for #{symbol} => #{price_usd_oz} (xau/xag)"
            end
          end
        end

        if price_usd_oz && usd_to_inr_used
          usd_per_g = price_usd_oz.to_f / OUNCE_TO_GRAM
          inr_per_g = usd_per_g * usd_to_inr_used.to_f
          # apply optional multiplier if present (to tune to Google/retail)
          multiplier = (ENV['METALS_RATE_MULTIPLIER'] || '1.0').to_f
          inr_per_g = inr_per_g * multiplier
          result[key] = inr_per_g.round(2)
        else
          Rails.logger.warn "MetalsClient: price missing for #{key} (price_usd_oz=#{price_usd_oz.inspect} usd_to_inr=#{usd_to_inr_used.inspect})"
          result[key] = nil
        end
      end

      # If a target per-10g for 24K is provided, compute and apply adjustment multiplier
      if result['gold'] && ENV['METALS_TARGET_24K_PER_10G'].present?
        begin
          target_10g = ENV['METALS_TARGET_24K_PER_10G'].to_f
          current_24k_per_10g = result['gold'].to_f * 10.0
          if current_24k_per_10g > 0
            adjust_multiplier = target_10g.to_f / current_24k_per_10g.to_f
            Rails.logger.info "MetalsClient: applying target multiplier #{adjust_multiplier} to match target_24k_per_10g=#{target_10g} (current=#{current_24k_per_10g})"
            # apply to all metals
            { 'gold' => 'gold', 'silver' => 'silver' }.each do |k_sym, k_key|
              if result[k_key]
                result[k_key] = (result[k_key].to_f * adjust_multiplier).round(2)
              end
            end
            # record in meta
            result['_meta'] ||= {}
            result['_meta']['target_24k_per_10g'] = target_10g
            result['_meta']['applied_multiplier_for_target'] = adjust_multiplier
          end
        rescue => e
          Rails.logger.warn "MetalsClient: failed to apply target_24k_per_10g #{e.class} #{e.message}"
        end
      end

        # If a target per-kg for silver is provided, adjust silver (and optionally other metals)
        if result['silver'] && ENV['METALS_TARGET_SILVER_PER_KG'].present?
          begin
            target_kg = ENV['METALS_TARGET_SILVER_PER_KG'].to_f
            current_per_kg = result['silver'].to_f * 1000.0
            if current_per_kg > 0
              adj = target_kg.to_f / current_per_kg.to_f
              Rails.logger.info "MetalsClient: applying silver target multiplier #{adj} to match target_silver_per_kg=#{target_kg} (current=#{current_per_kg})"
              # apply to all numeric metals values (gold/silver)
              result.keys.each do |k|
                next if k == '_meta'
                if result[k]
                  result[k] = (result[k].to_f * adj).round(2)
                end
              end
              result['_meta'] ||= {}
              result['_meta']['target_silver_per_kg'] = target_kg
              result['_meta']['applied_multiplier_for_silver_target'] = adj
            end
          rescue => e
            Rails.logger.warn "MetalsClient: failed to apply target_silver_per_kg #{e.class} #{e.message}"
          end
        end

      # include metadata for debugging / display
      result['_meta'] = { 'usd_to_inr' => usd_to_inr_used, 'source' => source }
      Rails.logger.info "MetalsClient: computed INR/g: #{result.inspect} (usd_to_inr=#{usd_to_inr_used})"
      begin
        Rails.cache.write(cache_key, result, expires_in: 10.minutes)
      rescue => e
        Rails.logger.warn "MetalsClient: failed to write cache #{e.class} #{e.message}"
      end
      result
    end

  private

  def fetch_price_from_gold_api(symbol)
    # symbol: 'XAU' or 'XAG'
    api_key = ENV['GOLD_API_KEY']
    url = GOLD_API_BASE + "/#{symbol}"
    url += "?api_key=#{api_key}" if api_key.present?
    Rails.logger.info "MetalsClient: GOLD API URL: #{url}"
    begin
      resp = URI.open(url, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
      parsed = begin; JSON.parse(resp); rescue => _; nil; end
      Rails.logger.info "MetalsClient: gold-api raw response for #{symbol}: #{resp.to_s[0..800]}"
      Rails.logger.info "MetalsClient: gold-api parsed for #{symbol}: #{parsed.inspect[0..800]}"
      if parsed.is_a?(Hash)
        price = parsed['price'] || parsed['value'] || parsed['result'] || (parsed['data'] && parsed['data']['price'])
        if price.nil? && parsed['rates'] && parsed['rates'][symbol]
          price = parsed['rates'][symbol]
        end
        return price.to_f if price
      elsif parsed.is_a?(Array)
        entry = parsed.find { |e| e.is_a?(Hash) && (e['metal']&.upcase == symbol || e['symbol'] == symbol) }
        if entry
          p = entry['price'] || entry['value']
          return p.to_f if p
        end
      end
    rescue => e
      Rails.logger.warn "MetalsClient: gold-api fetch failed for #{symbol}: #{e.class} #{e.message}"
    end
    nil
  end

  def fetch_usd_to_inr
    url = EXCHANGE_API + '?base=USD&symbols=INR'
    Rails.logger.info "MetalsClient: EXCHANGE API URL: #{url}"
    begin
      resp = URI.open(url, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
      parsed = begin; JSON.parse(resp); rescue => _; nil; end
      Rails.logger.info "MetalsClient: exchange raw response: #{resp.to_s[0..800]}"
      Rails.logger.info "MetalsClient: exchange parsed: #{parsed.inspect[0..800]}"
      if parsed.is_a?(Hash) && parsed['rates'] && parsed['rates']['INR']
        return parsed['rates']['INR'].to_f
      end

      # Try convert endpoint (sometimes more reliable)
      convert_url = 'https://api.exchangerate.host/convert?from=USD&to=INR'
      Rails.logger.info "MetalsClient: TRY CONVERT URL: #{convert_url}"
      resp_cv = URI.open(convert_url, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
      parsed_cv = begin; JSON.parse(resp_cv); rescue => _; nil; end
      Rails.logger.info "MetalsClient: convert parsed: #{parsed_cv.inspect[0..800]}"
      if parsed_cv.is_a?(Hash) && parsed_cv['result']
        return parsed_cv['result'].to_f
      end

      # fallback to alternative exchange APIs
      Rails.logger.warn "MetalsClient: exchangerate.host returned no INR rate, trying fallback APIs"
      fallback_urls = [
        'https://open.er-api.com/v6/latest/USD',
        'https://api.exchangerate-api.com/v4/latest/USD'
      ]
      fallback_urls.each do |furl|
        Rails.logger.info "MetalsClient: FALLBACK EXCHANGE URL: #{furl}"
        begin
          resp2 = URI.open(furl, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
          parsed2 = begin; JSON.parse(resp2); rescue => _; nil; end
          Rails.logger.info "MetalsClient: fallback parsed (#{furl}): #{parsed2.inspect[0..800]}"
          if parsed2.is_a?(Hash) && parsed2['rates'] && parsed2['rates']['INR']
            return parsed2['rates']['INR'].to_f
          end
        rescue => e
          Rails.logger.warn "MetalsClient: fallback fetch failed for #{furl}: #{e.class} #{e.message}"
        end
      end
    rescue => e
      Rails.logger.warn "MetalsClient: exchange fetch failed: #{e.class} #{e.message}"
    end
    nil
  end

  # Fallback public price source: data-asg.goldprice.org
  # returns JSON like { "items": [ { "xauPrice": 1961.23, "xagPrice": 23.45, ... } ] }
  def fetch_alt_goldprice
    url = 'https://data-asg.goldprice.org/dbXRates/USD'
    Rails.logger.info "MetalsClient: ALT GOLDPRICE URL: #{url}"
    begin
      resp = URI.open(url, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
      parsed = begin; JSON.parse(resp); rescue => _; nil; end
      Rails.logger.info "MetalsClient: alt goldprice raw: #{resp.to_s[0..800]}"
      if parsed.is_a?(Hash) && parsed['items'] && parsed['items'].first
        it = parsed['items'].first
        xau = it['xauPrice'] || it['xau'] || it['XAU']
        xag = it['xagPrice'] || it['xag'] || it['XAG']
        return { xau: xau.to_f, xag: xag.to_f }
      end
    rescue => e
      Rails.logger.warn "MetalsClient: alt goldprice fetch failed: #{e.class} #{e.message}"
    end
    nil
  end
end
