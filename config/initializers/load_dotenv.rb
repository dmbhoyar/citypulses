# Lightweight .env loader for local development (does not require dotenv gem)
path = Rails.root.join('.env')
if File.exist?(path)
  begin
    File.read(path).each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      key, val = line.split('=', 2)
      next unless key && val
      ENV[key] ||= val
    end
    Rails.logger.info "Loaded .env into ENV (#{path})"
  rescue => e
    Rails.logger.warn "Failed to load .env: #{e.message}"
  end
end
