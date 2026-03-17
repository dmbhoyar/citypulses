require 'open-uri'
require 'json'

# Simple weather client using Open-Meteo (no API key required)
class WeatherClient
  BASE = 'https://api.open-meteo.com/v1/forecast'

  # Fetch daily weather for given lat/lon and date range.
  # Returns a hash with :dates and arrays for :temp_max, :temp_min, :precipitation
  def fetch_daily_weather(lat:, lon:, start_date: nil, end_date: nil, timezone: 'auto')
    start_date ||= Date.current.strftime('%Y-%m-%d')
    end_date ||= (Date.current + 2).strftime('%Y-%m-%d')

    params = {
      latitude: lat,
      longitude: lon,
      daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum',
      timezone: timezone,
      start_date: start_date,
      end_date: end_date
    }

    query = URI.encode_www_form(params)
    url = "#{BASE}?#{query}"
    Rails.logger.info "WeatherClient: FULL API URL: #{url}"

    begin
      resp = URI.open(url, 'User-Agent' => 'CityPulses/1.0 (+https://example.com)', open_timeout: 8, read_timeout: 8).read
      parsed = JSON.parse(resp) rescue nil
      if parsed && parsed['daily']
        daily = parsed['daily']
        dates = daily['time'] || []
        temp_max = daily['temperature_2m_max'] || []
        temp_min = daily['temperature_2m_min'] || []
        precip = daily['precipitation_sum'] || []

        # build array of day hashes
        results = dates.each_with_index.map do |d, idx|
          {
            date: d,
            temp_max: temp_max[idx],
            temp_min: temp_min[idx],
            precipitation: precip[idx]
          }
        end

        { source: 'open-meteo', start_date: start_date, end_date: end_date, days: results }
      else
        Rails.logger.warn "WeatherClient: no daily data returned"
        { source: 'open-meteo', days: [] }
      end
    rescue OpenURI::HTTPError => e
      Rails.logger.warn "WeatherClient: fetch failed: #{e.message}"
      { source: 'open-meteo', days: [] }
    rescue => e
      Rails.logger.warn "WeatherClient: parse/connection failed: #{e.message}"
      { source: 'open-meteo', days: [] }
    end
  end
end
