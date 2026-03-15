# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Market.find_or_create_by!(city: 'City A') do |m|
	m.latitude = 19.075983
	m.longitude = 72.877655
	m.rate = 123.45
end

Market.find_or_create_by!(city: 'City B') do |m|
	m.latitude = 28.704060
	m.longitude = 77.102493
	m.rate = 130.10
end

Market.find_or_create_by!(city: 'City C') do |m|
	m.latitude = 13.082680
	m.longitude = 80.270718
	m.rate = 110.75
end

# Seed cities table (used for city selector)
City.find_or_create_by!(name: 'Washim') do |c|
	c.latitude = 20.1046
	c.longitude = 77.1426
end

City.find_or_create_by!(name: 'Mangrulpir') do |c|
	c.latitude = 20.3167
	c.longitude = 77.5047
end

City.find_or_create_by!(name: 'Karanja') do |c|
	c.latitude = 20.4833
	c.longitude = 77.4833
end

City.find_or_create_by!(name: 'Amravati') do |c|
	c.latitude = 20.9374
	c.longitude = 77.7796
end

City.find_or_create_by!(name: 'Shelubajar') do |c|
	c.latitude = 20.2
	c.longitude = 77.3
end
