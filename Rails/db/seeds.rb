# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts '🌱 Seeding database...'

Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |file|
  puts "Loading seed file: #{File.basename(file)}"
  load file
end

puts '🌱 Seeding done!'

# Create Orders
Current.user = user1
# debugger
order1 = Order.create!(offer: Offer.first)
order2 = Order.create!(offer: Offer.second)
order3 = Order.create!(offer: Offer.third)

Current.user = admin
order4 = Order.create!(offer: Offer.last)

ruby_image = File.open(Rails.root.join('db/seeds/files/ruby.jpg'))
darius_image = File.open(Rails.root.join('db/seeds/files/DariusSlayJunior.jpg'))

# Create Order Statuses
status_accepted = Status.create!(name: 'Accepted')
status_printing = Status.create!(name: 'Printing')
status_printed = Status.create!(name: 'Printed')
status_shipped = Status.create!(name: 'Shipped')
status_arrived = Status.create!(name: 'Arrived')
Status.create!(name: 'Cancelled')

Current.user = admin
OrderStatus.create!(order: order4, status: status_accepted, comment: 'offer accepted, printing soon.')

OrderStatus.create!(order: order3, status: status_accepted, comment: 'offer accepted, printing soon.')
OrderStatus.create!(order: order2, status: status_accepted, comment: 'offer accepted, printing soon.')
OrderStatus.create!(order: order2, status: status_printing, comment: 'Order started printing.')
OrderStatus.create!(order: order2, status: status_printed, comment: 'Order printed.')
OrderStatus.create!(order: order2, status: status_shipped, comment: 'Order shipped.')
orderstatus1 = OrderStatus.create!(order: order1, status: status_accepted, comment: 'offer accepted, printing soon.')
OrderStatus.create!(order: order1, status: status_printing, comment: 'Order started printing.')

orderstatus1.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)
orderstatus1.save

Current.user = user1
OrderStatus.create!(order: order2, status: status_arrived, comment: 'Order arrived.')
ruby_image.rewind
darius_image.rewind

r1 = Review.create!(
  order: order2,
  user: user1,
  title: 'Durable and Precise',
  description: 'Prototype case fit perfectly, highly recommend!',
  rating: 4
)
r1.images.attach([
                   { io: ruby_image, filename: 'ruby.jpg', content_type: 'image/jpg' },
                   { io: darius_image, filename: 'DariusSlayJunior.jpg', content_type: 'image/jpg' }
                 ])
r1.save

puts '✅ Seeding complete!'

# rails db:drop; rails db:create; rails db:migrate; rails db:seed
