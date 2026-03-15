require 'net/http'
require 'uri'
require 'json'

# Simple government market API client. Configure endpoint via ENV['GOV_MARKET_API_URL']
class GovMarketClient
  DEFAULT_URL = ENV.fetch('GOV_MARKET_API_URL', 'https://example.gov/market_rates')

  # Fetch rates for a given city or district name. This method expects the external
  # API to accept a `location` and return JSON with [{"commodity":"soybean","rate":123.45,"date":"2026-03-15"}, ...]
  def fetch_rates_for(location)
    uri = URI.parse(DEFAULT_URL)
    uri.query = URI.encode_www_form(location: location)

    res = Net::HTTP.get_response(uri)
    return [] unless res.is_a?(Net::HTTPSuccess)

    begin
      JSON.parse(res.body)
    rescue JSON::ParserError
      []
    end
  rescue StandardError
    []
  end
end
