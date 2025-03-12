# frozen_string_literal: true

# Create Colors
colors = %w[Red Blue Green Yellow Black White Orange Purple Pink Brown Gray]
colors.each do |color|
  Color.create!(name: color)
end

# Create Filaments
filaments = ['PETG', 'TPU', 'Nylon', 'Wood', 'Metal', 'Carbon Fiber']
filaments.each do |filament|
  Filament.create!(name: filament)
end

# Create countries
[
  { name: 'United States', id: 1 },
  { name: 'Canada', id: 2 },
  { name: 'France', id: 3 },
  { name: 'Germany', id: 4 },
  { name: 'Italy', id: 5 },
  { name: 'Spain', id: 6 },
  { name: 'United Kingdom', id: 7 },
  { name: 'Australia', id: 8 },
  { name: 'Brazil', id: 9 },
  { name: 'China', id: 10 },
  { name: 'India', id: 11 },
  { name: 'Japan', id: 12 },
  { name: 'Mexico', id: 13 },
  { name: 'Russia', id: 14 },
  { name: 'South Africa', id: 15 }
].each do |country|
  Country.create!(name: country[:name])
end

# Create Users
User.create!(
  username: 'aaadmin',
  password: 'aaaaaa',
  password_confirmation: 'aaaaaa',
  country_id: 1,
  is_admin: true
)

user1 = User.create!(
  username: 'aaa',
  password: 'aaaaaa',
  password_confirmation: 'aaaaaa',
  country_id: 2,
  is_admin: false
)
user1.profile_picture.attach(
  io: File.open(Rails.root.join('db/seeds/files/ruby.jpg')),
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

user2 = User.create!(
  username: 'bbb',
  password: 'bbbbbb',
  password_confirmation: 'bbbbbb',
  country_id: 2,
  is_admin: false
)

user2.profile_picture.attach(
  io: File.open(Rails.root.join('db/seeds/files/ruby.jpg')),
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

user2.save

user3 = User.create!(
  username: 'ccc',
  password: 'cccccc',
  password_confirmation: 'cccccc',
  country_id: 3,
  is_admin: false
)

user3.save
