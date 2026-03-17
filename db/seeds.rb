# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seed cities table (used for city selector)
washim = City.find_or_create_by!(name: 'Washim') do |c|
  c.latitude = 20.1046
  c.longitude = 77.1426
  c.agmarknet_district = 'vashim'
  c.agmarknet_state = 'Maharashtra'
  c.agmarknet_market = 'Washim (Main)'
end

mang = City.find_or_create_by!(name: 'Mangrulpir') do |c|
  c.latitude = 20.3167
  c.longitude = 77.5047
  c.agmarknet_district = 'vashim'
  c.agmarknet_state = 'Maharashtra'
  c.agmarknet_market = 'Mangrulpir'
end

kar = City.find_or_create_by!(name: 'Karanja') do |c|
  c.latitude = 20.4833
  c.longitude = 77.4833
  c.agmarknet_district = 'vashim'
  c.agmarknet_state = 'Maharashtra'
  c.agmarknet_market = 'Karanja (APMC)'
end

amr = City.find_or_create_by!(name: 'Amravati') do |c|
  c.latitude = 20.9374
  c.longitude = 77.7796
  c.agmarknet_district = 'Amravati'
  c.agmarknet_state = 'Maharashtra'
  c.agmarknet_market = 'Amarawati'
end

shel = City.find_or_create_by!(name: 'Shelubajar') do |c|
  c.latitude = 20.2
  c.longitude = 77.3
  c.agmarknet_district = 'Shelubajar'
  c.agmarknet_state = 'Maharashtra'
  c.agmarknet_market = 'Shelubajar'
end

  akola = City.find_or_create_by!(name: 'Akola') do |c|
    c.latitude = 20.7167
    c.longitude = 77.0
    c.agmarknet_district = 'Akola'
    c.agmarknet_state = 'Maharashtra'
    c.agmarknet_market = 'Akola'
  end

# Markets (attach to City records)
Market.find_or_create_by!(city_id: washim.id) do |m|
  m[:city] = 'Washim (Main)'
  m.district = washim.agmarknet_district
  m.latitude = washim.latitude
  m.longitude = washim.longitude
  m.rate = 123.45
end

Market.find_or_create_by!(city_id: amr.id) do |m|
  m[:city] = 'Amravati'
  m.district = amr.agmarknet_district
  m.latitude = amr.latitude
  m.longitude = amr.longitude
  m.rate = 130.10
end

Market.find_or_create_by!(city_id: kar.id) do |m|
  m[:city] = 'Karanja (APMC)'
  m.district = kar.agmarknet_district
  m.latitude = kar.latitude
  m.longitude = kar.longitude
  m.rate = 110.75
end

# Create a demo superadmin and a shopowner for testing
User.find_or_create_by!(email: 'admin@example.com') do |u|
	u.first_name = 'Admin'
	u.last_name = 'User'
	u.password = 'password123'
	u.role = 'superadmin'
end

User.find_or_create_by!(email: 'shopowner@example.com') do |u|
	u.first_name = 'Shop'
	u.last_name = 'Owner'
	u.password = 'password123'
	u.role = 'shopowner'
end

# demo shop for shopowner
shop_owner = User.find_by(email: 'shopowner@example.com')
if shop_owner && shop_owner.shops.count == 0
	Shop.create!(name: 'Demo Shop', description: 'Demo local shop', phone: '0000000000', address: 'Demo address', user: shop_owner, city: City.find_by(name: 'Washim'))
end

# demo farming notes
Farming.find_or_create_by!(title: 'Soya bean harvest tips') do |f|
	f.content = 'Ensure timely sowing and use certified seeds. Monitor moisture.'
	f.city = City.find_by(name: 'Washim')
end

Farming.find_or_create_by!(title: 'Bee keeping basics') do |f|
	f.content = 'Bees increase pollination; keep boxes shaded and water available.'
end

