# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Seeding database..."
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
    Country.create!(name: country[:name], )
end

# Create Users
admin = User.create!(
  username: "aaadmin",
  password: "aaaaaa",
  password_confirmation: "aaaaaa",
  country_id: 1,
  is_admin: true
)

user1 = User.create!(
  username: "aaa",
  password: "aaaaaa",
  password_confirmation: "aaaaaa",
  country_id: 2,
  is_admin: false
)

# Create Printers
printer1 = Printer.create!(model: "Creality Ender 3")
printer2 = Printer.create!(model: "Prusa i3 MK3S+")

# Assign Printers to Users
PrinterUser.create!(user: admin, printer: printer1, acquired_date: Time.now)
PrinterUser.create!(user: user1, printer: printer2, acquired_date: Time.now - 1.year)

# Create Colors
color_red = Color.create!(name: "Red")
color_blue = Color.create!(name: "Blue")

# Create Filaments
filament_pla = Filament.create!(name: "PLA", size: 1.75)
filament_abs = Filament.create!(name: "ABS", size: 2.85)

# Create Presets
preset1 = Preset.create!(color: color_red, filament: filament_pla, user: admin)
preset2 = Preset.create!(color: color_blue, filament: filament_abs, user: user1)
preset3 = Preset.create!(color: color_red, filament: filament_abs, user: user1)

# Create Contests
contest1 = Contest.create!(
  theme: "Best 3D Printed Art",
  description: "Create and submit your best 3D printed designs.",
  submission_limit: 5,
  start_at: Time.now,
  end_at: Time.now + 30.days
)

# Create Submissions
submission1 = Submission.create!(
  name: "3D Dragon",
  description: "A detailed dragon model.",
  user: admin,
  contest: contest1
)

submission2 = Submission.create!(
  name: "Space Shuttle",
  description: "NASA space shuttle model.",
  user: user1,
  contest: contest1
)

# Likes for Submissions
Like.create!(user: admin, submission: submission2)
Like.create!(user: user1, submission: submission1)

stl_file_path1 = Rails.root.join("db/seeds/files/RUBY13.stl")

# Create Requests
request1 = Request.create(
  user: admin,
  name: "Custom Chess Set",
  budget: 50.0,
  comment: "Need a high-quality chess set with intricate pieces.",
  target_date: Time.now + 10.days
)

request1.stl_file.attach(
    io: File.open(stl_file_path1),
    filename: "RUBY13.stl",
    content_type: "application/sla"
  )
  request1.save

request2 = Request.create(
  user: user1,
  name: "Prototype Case",
  budget: 100.0,
  comment: "Looking for a durable case prototype.",
  target_date: Time.now + 15.days
)

request2.stl_file.attach(
    io: File.open(stl_file_path1),
    filename: "RUBY13.stl",
    content_type: "application/sla"
  )
  request2.save


# Create Preset Requests
PresetRequest.create!(request_id: request1.id, color_id: color_red.id, filament_id: filament_pla.id)
PresetRequest.create!(request_id: request2.id, color_id: color_blue.id, filament_id: filament_abs.id)

# Create Offers
offer1 = Offer.create!(
  request: request1,
  printer_user: PrinterUser.first,
  color: color_red,
  filament: filament_pla,
  price: 45.0,
  target_date: Time.now + 9.days
)

offer2 = Offer.create!(
  request: request2,
  printer_user: PrinterUser.last,
  color: color_blue,
  filament: filament_abs,
  price: 95.0,
  target_date: Time.now + 14.days
)

# Create Orders
order1 = Order.create!(offer: offer1)
order2 = Order.create!(offer: offer2)

Review.create!(
  order: order2,
  user: user1,
  title: "Durable and Precise",
  description: "Prototype case fit perfectly, highly recommend!",
  rating: 4
)

# Create Order Statuses
status_accepted = Status.create!(name: "Accepted")
status_printing = Status.create!(name: "Printing")
status_printed = Status.create!(name: "Printed")
status_shipped = Status.create!(name: "Shipped")
status_arrived = Status.create!(name: "Arrived")
status_cancelled = Status.create!(name: "Cancelled")

OrderStatus.create!(order: order2, status: status_arrived, comment: "Order successfully delivered.")
orderstatus1 = OrderStatus.create!(order: order1, status: status_accepted, comment: "offer accepted, printing soon.")
orderstatus1.images.attach(
  io: File.open(Rails.root.join("db/seeds/files/ruby.jpg")),
  filename: "ruby.jpg",
  content_type: "image/jpg"
)
orderstatus1.save


puts "✅ Seeding complete!"

# rails db:drop; rails db:create; rails db:migrate; rails db:seed