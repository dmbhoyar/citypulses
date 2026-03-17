namespace :imports do
  desc 'Import market rates from Agmarknet for all cities'
  task agmarknet: :environment do
    require_relative '../../lib/agmarknet_client'
    client = AgmarknetClient.new
    City.find_each do |city|
      puts "Fetching rates for #{city.name}..."
      rows = client.fetch_rates_for_district(city.name)
      rows.each do |r|
        next unless r[:commodity] && r[:modal_price]
        market = Market.create(
          city: city.name,
          city_id: city.id,
          commodity: r[:commodity],
          min_price: r[:min_price],
          max_price: r[:max_price],
          modal_price: r[:modal_price],
          price_date: r[:date]
        )
      end
    end
    puts 'Agmarknet import completed.'
  end

  desc 'Fetch news RSS feeds and create updates'
  task news: :environment do
    require_relative '../../lib/news_fetcher'
    feeds = [
      'https://rss.cnn.com/rss/edition.rss',
      'https://timesofindia.indiatimes.com/rssfeeds/-2128936835.cms'
    ]
    nf = NewsFetcher.new(feeds)
    nf.fetch
    puts 'News fetch completed.'
  end
end
