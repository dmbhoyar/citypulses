require 'open-uri'
require 'nokogiri'
require 'json'

# Minimal Agmarknet client: fetches commodity rates for a district/state

class AgmarknetClient
  API_URL = 'https://api.data.gov.in/resource/35985678-0d79-46b4-9ed6-6f13308a1d24'
  API_KEY = ENV['DATA_GOV_API_KEY'] || '579b464db66ec23bdd000001cdc3b564546246a772a26393094f5645'

  # Fetch and return parsed records from the API, using dynamic filters from arguments or system
  # Arguments: state, district, date_from, date_to, sort (hash, e.g. { 'Market' => 'desc' })
  def fetch_market_data(state:, district:, date_from:, date_to:, sort: { 'Market' => 'desc' })
    # Ensure first letter uppercase, rest lowercase for state and district
    state = state.to_s.strip.capitalize
    district = district.to_s.strip.capitalize
    params = {
      'format' => 'json',
      'api-key' => API_KEY,
      'filters[State]' => state,
      'filters[District]' => district,
      'range[Arrival_Date][gte]' => date_from,
      'range[Arrival_Date][lte]' => date_to
    }
    if sort.is_a?(Hash)
      sort.each { |field, dir| params["sort[#{field}]"] = dir }
    end
    query = URI.encode_www_form(params)
    url = "#{API_URL}?#{query}"
    Rails.logger.info "AgmarknetClient: FULL API URL: #{url}"
    begin
      resp = URI.open(url, 'User-Agent' => 'CityPulses/1.0 (+https://example.com)', open_timeout: 12, read_timeout: 12).read
      parsed = JSON.parse(resp) rescue nil
      return parsed['records'] if parsed.is_a?(Hash) && parsed['records'].is_a?(Array)
      []
    rescue OpenURI::HTTPError => e
      Rails.logger.warn "AgmarknetClient: data.gov fetch failed: #{e.message}"
      []
    rescue => e
      Rails.logger.warn "AgmarknetClient: data.gov parse failed: #{e.message}"
      []
    end
  end

  # Group data marketwise and datewise, show commodities dynamically
  # Accepts same arguments as fetch_market_data
  def group_market_date_commodity(state:, district:, date_from:, date_to:, sort: { 'Market' => 'desc' })
    records = fetch_market_data(state: state, district: district, date_from: date_from, date_to: date_to, sort: sort)
    grouped = {}
    records.each do |rec|
      market = rec['Market']
      date = rec['Arrival_Date']
      commodity = rec['Commodity']
      grouped[market] ||= {}
      grouped[market][date] ||= {}
      grouped[market][date][commodity] ||= []
      grouped[market][date][commodity] << rec
    end
    grouped
  end

  # Fetch daily market rates for a district. By default this delegates to Data.gov.
  # Set ENV['AGMARKNET_USE_SCRAPE']='1' to enable legacy scraping of agmarknet.gov.in.
  def fetch_rates_for_district(district_name)
    if ENV['AGMARKNET_USE_SCRAPE'] == '1'
      encoded = URI.encode_www_form_component(district_name)
      url = "#{BASE}/Prices/CommodityWise/DistrictWisePricesReport.aspx?Tx_Commodity=0&Tx_State=&Tx_District=#{encoded}&Tx_Market=0&DateFrom=&DateTo=&Fr_Date=&To_Date=&Tx_Trend=0"
      Rails.logger.info "AgmarknetClient: scraping enabled; fetching #{url}"
      begin
        html = URI.open(url, 'User-Agent' => 'CityPulses/1.0 (+https://example.com)', open_timeout: 12, read_timeout: 12).read
        doc = Nokogiri::HTML(html)
        rows = []
        table = doc.at_css('table#cphbody_tbl_Data') || doc.at_css('table.dataTable') || doc.at_css('table')
        if table
          table.css('tr')[1..-1].to_a.each do |tr|
            cols = tr.css('td').map { |c| c.text.gsub("\u00A0", ' ').strip }
            next if cols.empty?
            rows << {
              commodity: cols[0],
              variety: cols[1],
              market: cols[2],
              min_price: to_number(cols[3]),
              max_price: to_number(cols[4]),
              modal_price: to_number(cols[5]),
              date: (parse_date(cols[6]) rescue nil),
              city: district_name
            }
          end
        else
          Rails.logger.info "AgmarknetClient: scraping enabled but table not found for #{district_name}"
        end
        rows
      rescue => e
        Rails.logger.warn "AgmarknetClient: scraping failed: #{e.message}"
        []
      end
    else
      Rails.logger.info "AgmarknetClient: delegating fetch_rates_for_district to Data.gov API for #{district_name}"
      fetch_rates_from_data_gov(district_name)
    end
  end

  def to_number(str)
    return nil if str.nil? || (str.respond_to?(:strip) && str.strip.empty?) || str == '-'
    str.to_s.gsub(',','').to_f
  end

  def parse_date(s)
    return nil if s.nil? || (s.respond_to?(:strip) && s.strip.empty?)
    # Accept common formats like dd/MM/yyyy or ISO
    begin
      if s.to_s =~ %r{\d{1,2}/\d{1,2}/\d{4}}
        day, mon, year = s.to_s.split('/')
        Date.parse("#{year}-#{mon}-#{day}")
      else
        Date.parse(s.to_s) rescue nil
      end
    rescue
      nil
    end
  end
end
