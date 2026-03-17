require 'open-uri'
require 'rss'

# Fetch RSS feeds and create Update records (if unique)
class NewsFetcher
  # feeds: array of RSS feed URLs
  def initialize(feeds = [])
    @feeds = feeds
  end

  def fetch(limit_per_feed: 10)
    @feeds.each do |url|
      begin
        content = URI.open(url, open_timeout: 10, read_timeout: 10).read
        rss = RSS::Parser.parse(content, false)
        items = rss.items.first(limit_per_feed)
        items.each do |item|
          next if Update.exists?(source_url: item.link)
          Update.create(title: item.title || 'Untitled', content: (item.description || item.content || '').to_s.truncate(1000), source_url: item.link, published_at: item.pubDate || Time.current)
        end
      rescue => e
        Rails.logger.warn "NewsFetcher failed for #{url}: #{e.message}"
      end
    end
  end
end
