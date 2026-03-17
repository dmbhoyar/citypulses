require 'open-uri'
require 'rss'

# Simple fetcher to import government job announcements from RSS feeds
class GovJobsFetcher
  def initialize(feeds = [])
    @feeds = feeds
  end

  def fetch
    @feeds.each do |url|
      begin
        content = URI.open(url, open_timeout: 10, read_timeout: 10).read
        rss = RSS::Parser.parse(content, false)
        rss.items.each do |item|
          next if Job.exists?(external_url: item.link)
          Job.create(title: item.title, description: item.description.to_s.truncate(2000), external_url: item.link)
        end
      rescue => e
        Rails.logger.warn "GovJobsFetcher failed for #{url}: #{e.message}"
      end
    end
  end
end
