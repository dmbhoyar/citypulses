class ImportsJob < ApplicationJob
  queue_as :default

  def perform
    # Import market rates
    begin
      client = AgmarknetClient.new
      City.find_each do |city|
        rows = client.fetch_rates_for_district(city.name)
        rows.each do |r|
          next unless r[:commodity] && (r[:modal_price] || r[:min_price] || r[:max_price])
          attrs = {
            city: city.name,
            city_id: city.id,
            commodity: r[:commodity],
            min_price: r[:min_price],
            max_price: r[:max_price],
            modal_price: r[:modal_price],
            price_date: r[:date],
            source_url: r[:source_url]
          }
          market = Market.find_or_initialize_by(city_id: city.id, commodity: r[:commodity], price_date: r[:date])
          market.assign_attributes(attrs)
          market.save
        end
      end
    rescue => e
      Rails.logger.error "ImportsJob Agmarknet import failed: #{e.message}" 
    end

    # Import news feeds
    begin
      feeds = [
        'https://rss.cnn.com/rss/edition.rss',
        'https://timesofindia.indiatimes.com/rssfeeds/-2128936835.cms'
      ]
      nf = NewsFetcher.new(feeds)
      nf.fetch
    rescue => e
      Rails.logger.error "ImportsJob news fetch failed: #{e.message}"
    end
  end
end
