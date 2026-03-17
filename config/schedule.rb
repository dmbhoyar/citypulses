# Use with the `whenever` gem to write cron entries.
# Example: run `whenever --update-crontab` to install.

set :output, 'log/cron.log'

# Run imports daily at 06:00
every 1.day, at: '6:00 am' do
  runner "ImportsJob.perform_later"
end

# Optional: fetch news twice daily
every 12.hours do
  rake 'imports:news'
end
