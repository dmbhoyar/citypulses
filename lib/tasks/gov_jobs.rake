namespace :imports do
  desc 'Import government job announcements from RSS'
  task govjobs: :environment do
    require_relative '../../lib/gov_jobs_fetcher'
    feeds = [
      'https://www.govtjobsalert.com/rss',
      'https://www.sarkariresult.com/rss'
    ]
    g = GovJobsFetcher.new(feeds)
    g.fetch
    puts 'Gov jobs import completed.'
  end
end
