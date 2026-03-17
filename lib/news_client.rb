require 'open-uri'
require 'rexml/document'

# Simple news client using Google News RSS search (no API key required)
class NewsClient
  # Fetch news items for a city. Returns array of hashes: { title, link, pubDate, source }
  def fetch_city_news(city_name, country: 'India', limit: 4)
    return [] if city_name.to_s.strip.empty?
    query = URI.encode_www_form_component("#{city_name} #{country}")
    url = "https://news.google.com/rss/search?q=#{query}&hl=en-IN&gl=IN&ceid=IN:en"
    Rails.logger.info "NewsClient: fetching news URL: #{url}"
    begin
      body = URI.open(url, 'User-Agent' => 'CityPulses/1.0', open_timeout: 6, read_timeout: 6).read
      doc = REXML::Document.new(body)
      items = []
      doc.elements.each('rss/channel/item') do |it|
        title = it.elements['title'] && it.elements['title'].text
        link = it.elements['link'] && it.elements['link'].text
        pubDate = it.elements['pubDate'] && it.elements['pubDate'].text
        source_el = it.elements['source']
        source = source_el && source_el.text
        items << { title: title.to_s, link: link.to_s, pubDate: pubDate && pubDate.to_s, source: source }
        break if items.size >= limit
      end
      Rails.logger.info "NewsClient: fetched #{items.size} items for #{city_name}"
      items
    rescue => e
      Rails.logger.warn "NewsClient: fetch failed for #{city_name}: #{e.class} #{e.message}"
      []
    end
  end
end
