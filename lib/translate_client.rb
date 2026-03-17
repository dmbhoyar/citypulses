require 'open-uri'
require 'json'

# Simple translate client using LibreTranslate (or configured endpoint)
class TranslateClient
  DEFAULT_URL = ENV.fetch('TRANSLATE_URL', 'https://libretranslate.de')

  def self.translate(text, source: 'auto', target: 'en')
    return text.to_s if text.to_s.strip.empty? || target.to_s == ''
    url = URI.join(DEFAULT_URL, '/translate')
    payload = { q: text.to_s, source: source.to_s, target: target.to_s, format: 'text' }
    begin
      Rails.logger.info "TranslateClient: translating to #{target} via #{url}"
      resp = URI.open(url.to_s, **translate_open_options(payload)).read
      data = JSON.parse(resp) rescue {}
      translated = data['translatedText'] || data['translation'] || text
      translated.to_s
    rescue => e
      Rails.logger.warn "TranslateClient: translate failed: #{e.class} #{e.message}"
      text.to_s
    end
  end

  def self.translate_open_options(payload)
    opts = { 'Content-Type' => 'application/json' }
    body = JSON.generate(payload)
    # Use POST via open-uri with data
    { 'User-Agent' => 'CityPulses/1.0', :read_timeout => 6, :open_timeout => 6, :method => :post, :data => body }
  end
end
