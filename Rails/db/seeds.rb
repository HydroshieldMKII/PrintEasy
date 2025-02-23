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
user1.profile_picture.attach(
  io: File.open(Rails.root.join("db/seeds/files/ruby.jpg")),
  filename: "ruby.jpg",
  content_type: "image/jpg"
)

# Create Printers
printers = ["Bambulab", "Anycubic", "Artillery", "Creality", "Elegoo", "Flashforge", "Monoprice", "Prusa", "Qidi", "Sindoh", "Ultimaker", "XYZprinting", "Zortrax"]
printers.each do |printer|
  Printer.create!(model: printer)
end

# Assign Printers to Users
PrinterUser.create!(user: user1, printer: Printer.first, acquired_date: Time.now)
PrinterUser.create!(user: user1, printer: Printer.second, acquired_date: Time.now - 1.year)
PrinterUser.create!(user: user1, printer: Printer.third, acquired_date: Time.now - 2.years)

# Create Colors
colors = ["Red", "Blue", "Green", "Yellow", "Black", "White", "Orange", "Purple", "Pink", "Brown", "Gray"]
colors.each do |color|
  Color.create!(name: color)
end

# Create Filaments
filaments = ["PETG", "TPU", "Nylon", "Wood", "Metal", "Carbon Fiber"]
filaments.each do |filament|
  Filament.create!(name: filament)
end

# Create Presets
presets = [
  { color: Color.find_by(name: "Red"), filament: Filament.find_by(name: "PETG"), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: "Blue"), filament: Filament.find_by(name: "TPU"), user: user1, print_quality: 0.12 },
  { color: Color.find_by(name: "Green"), filament: Filament.find_by(name: "Nylon"), user: admin, print_quality: 0.16 },
  { color: Color.find_by(name: "Yellow"), filament: Filament.find_by(name: "Wood"), user: user1, print_quality: 0.2 },
  { color: Color.find_by(name: "Black"), filament: Filament.find_by(name: "Metal"), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: "White"), filament: Filament.find_by(name: "Carbon Fiber"), user: user1, print_quality: 0.12 },
  { color: Color.find_by(name: "Orange"), filament: Filament.find_by(name: "PETG"), user: admin, print_quality: 0.16 },
  { color: Color.find_by(name: "Purple"), filament: Filament.find_by(name: "TPU"), user: user1, print_quality: 0.2 },
  { color: Color.find_by(name: "Pink"), filament: Filament.find_by(name: "Nylon"), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: "Brown"), filament: Filament.find_by(name: "Wood"), user: user1, print_quality: 0.12 }
]

presets.each do |preset|
  Preset.create!(preset)
end

stl_file_path1 = Rails.root.join("db/seeds/files/RUBY13.stl")

5.times do |i|
  req = Request.create(
    user: admin,
    name: "Admin Request #{i + 1}",
    budget: (i + 1) * 20.0,
    comment: "This is request number #{i + 1} from admin.",
    target_date: Time.now + (i + 5).days
  )

  # Attach STL file to request
  req.stl_file.attach(
    io: File.open(stl_file_path1),
    filename: "RUBY13.stl",
    content_type: "application/sla"
  )

  req.stl_file.attach(
    io: File.open(stl_file_path1),
    filename: "RUBY13.stl",
    content_type: "application/sla"
  )
  req.save
end

10.times do |i|
  req = Request.create(
    user: user1,
    name: "User Request #{i + 1}",
    budget: (i + 1) * 15.0,
    comment: "This is request number #{i + 1} from user.",
    target_date: Time.now + (i + 10).days
  )

  # Attach STL file to request
  req.stl_file.attach(
    io: File.open(stl_file_path1),
    filename: "RUBY13.stl",
    content_type: "application/sla"
  )
  req.save
end

# Create Preset Requests for each Request
Request.all.each do |request|
  colors = Color.all
  filaments = Filament.all
  printers = Printer.all
  print_qualities = [0.08, 0.12, 0.16, 0.2]

  rand(0..3).times do |i|
    PresetRequest.create!(
      request: request,
      color: colors[i % colors.size],
      filament: filaments[i % filaments.size],
      printer: printers[i % printers.size],
      print_quality: print_qualities[i % print_qualities.size]
    )
  end
end

# Create Contests
contest1 = Contest.create(
  theme: "Best 3D Printed Art",
  description: "Create and submit your best 3D printed designs.",
  submission_limit: 5,
  start_at: Time.now,
  end_at: Time.now + 30.days
)

contest1.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)
contest1.save

contest2 = Contest.create(
  theme: "Best 3D Printed Toy",
  description: "Create and submit your best 3D printed toys.",
  submission_limit: 5,
  deleted_at: Time.now,
  start_at: Time.now
)

contest2.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)
contest2.save

contest3 = Contest.create(
  theme: "Best 3D Printed Jewelry",
  description: "Create and submit your best 3D printed jewelry.",
  submission_limit: 5,
  start_at: Time.now
)

contest3.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest3.save

contest4 = Contest.create(
  theme: "Best 3D Printed Home Decor",
  description: "Create and submit your best 3D printed home decor.",
  submission_limit: 5,
  deleted_at: Time.now,
  start_at: Time.now,
  end_at: Time.now + 30.days
)

contest4.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest4.save

contest5 = Contest.create(
  theme: "Best 3D Printed Fashion",
  submission_limit: 5,
  start_at: Time.now,
  end_at: Time.now + 30.days
)

contest5.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest5.save

contest6 = Contest.create(
  theme: "Best 3D Printed Gadgets",
  submission_limit: 5,
  start_at: Time.now,
  deleted_at: Time.now
)

contest6.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest6.save

contest7 = Contest.create(
  theme: "Best 3D Printed Tools",
  submission_limit: 5,
  start_at: Time.now,
)

contest7.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest7.save

contest8 = Contest.create(
  theme: "Best 3D Printed Medical Devices",
  submission_limit: 5,
  start_at: Time.now,
  end_at: Time.now + 30.days
)

contest8.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest8.save

contest9 = Contest.create(
  theme: "Best 3D Printed Automotive Parts",
  submission_limit: 5,
  start_at: Time.now,
  deleted_at: Time.now,
  end_at: Time.now + 30.days
)

contest9.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

contest9.save

50.times do |i|
  contest = Contest.create(
    theme: "Contest #{i + 3}",
    description: "Description for contest #{i + 3}.",
    submission_limit: 5,
    start_at: Time.now,
    end_at: Time.now + 30.days
  )

  contest.image.attach(
    io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
    filename: "DariusSlayJunior.jpg",
    content_type: "image/jpg"
  )
  contest.save
end
# Create Submissions
submission1 = Submission.create(
  name: "3D Dragon",
  description: "A detailed dragon model.",
  user: admin,
  contest: contest1
)

submission1.files.attach(
  io: File.open(Rails.root.join("db/seeds/files/RUBY13.stl")),
  filename: "RUBY13.stl",
  content_type: "application/sla"
)

submission1.files.attach(
  io: File.open(Rails.root.join("db/seeds/files/DariusSlayJunior.jpg")),
  filename: "DariusSlayJunior.jpg",
  content_type: "image/jpg"
)

submission1.save

submission2 = Submission.create(
  name: "Space Shuttle",
  description: "NASA space shuttle model.",
  user: user1,
  contest: contest1
)

submission2.files.attach(
  io: File.open(Rails.root.join("db/seeds/files/RUBY13.stl")),
  filename: "RUBY13.stl",
  content_type: "application/sla"
)
submission2.save

# Likes for Submissions
Like.create!(user: admin, submission: submission2)
Like.create!(user: user1, submission: submission1)

# Create Offers
colors = Color.all
filaments = Filament.all
printer_users = PrinterUser.all

Request.all.each do |request|
  rand(1..5).times do |i|
    Offer.create!(
      request: request,
      printer_user: printer_users[i % printer_users.size],
      color: colors[i % colors.size],
      filament: filaments[i % filaments.size],
      price: rand(20.0..100.0).round(2),
      target_date: Time.now + rand(5..15).days,
      print_quality: [0.08, 0.12, 0.16, 0.2][i % 4]
    )
  end
end



#Request without offers
req_no_offer = Request.create(
  user: user1,
  name: "Request without offers",
  budget: 100.0,
  comment: "This request has no offers.",
  target_date: Time.now + 10.days
)

req_no_offer.stl_file.attach(
  io: File.open(stl_file_path1),
  filename: "RUBY13.stl",
  content_type: "application/sla"
)
req_no_offer.save

#Request 0$ budget
req_free = Request.create(
  user: user1,
  name: "Request with 0$ budget",
  budget: 0.0,
  comment: "This request has 0$ budget.",
  target_date: Time.now + 10.days
)

req_free.stl_file.attach(
  io: File.open(stl_file_path1),
  filename: "RUBY13.stl",
  content_type: "application/sla"
)

req_free.save


# Create Orders
order1 = Order.create!(offer: Offer.first)
order2 = Order.create!(offer: Offer.second)
order3 = Order.create!(offer: Offer.third)
order4 = Order.create!(offer: Offer.last)

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

OrderStatus.create!(order: order4, status: status_accepted, comment: "offer accepted, printing soon.")
OrderStatus.create!(order: order3, status: status_accepted, comment: "offer accepted, printing soon.")
OrderStatus.create!(order: order2, status: status_accepted, comment: "offer accepted, printing soon.")
OrderStatus.create!(order: order2, status: status_printing, comment: "Order started printing.")
OrderStatus.create!(order: order2, status: status_printed, comment: "Order printed.")
OrderStatus.create!(order: order2, status: status_shipped, comment: "Order shipped.")
orderstatus1 = OrderStatus.create!(order: order1, status: status_accepted, comment: "offer accepted, printing soon.")
OrderStatus.create!(order: order1, status: status_printing, comment: "Order started printing.")
orderstatus1.image.attach(
  io: File.open(Rails.root.join("db/seeds/files/ruby.jpg")),
  filename: "ruby.jpg",
  content_type: "image/jpg"
)
orderstatus1.save


puts "✅ Seeding complete!"

# rails db:drop; rails db:create; rails db:migrate; rails db:seed