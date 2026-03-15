namespace :market_rates do
  desc 'Fetch market rates from configured government API and import into MarketRate'
  task import: :environment do
    client = GovMarketClient.new
    commodities_sample = %w[soybean toor wheat]

    City.find_each do |city|
      puts "Fetching rates for #{city.name}"
      data = client.fetch_rates_for(city.name)
      next if data.blank?

      data.each do |entry|
        # expected keys: commodity, rate, date
        commodity = entry['commodity'] || entry['name'] || entry['commodity_name']
        value = entry['rate'] || entry['price']
        date = entry['date'] ? Date.parse(entry['date']) rescue Date.current : Date.current

        next unless commodity && value

        MarketRate.create_with(latitude: city.latitude, longitude: city.longitude, source: GovMarketClient::DEFAULT_URL)
                  .find_or_create_by(city: city, commodity: commodity, recorded_at: date) do |mr|
          mr.rate = value
        end
      end
    end
  end
end
