# frozen_string_literal: true

admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')
User.find_by(username: 'bbb')

stl_file_path = File.open(Rails.root.join('db/seeds/files/RUBY13.stl'))

admin_historical_requests = [
  {
    name: 'Admin Historical Request 1',
    budget: 50.00,
    comment: 'Historical request from early 2023',
    created_at: Time.new(2023, 1, 15),
    target_date: Time.new(2023, 1, 30)
  },
  {
    name: 'Admin Historical Request 2',
    budget: 65.00,
    comment: 'Historical request from mid 2023',
    created_at: Time.new(2023, 6, 10),
    target_date: Time.new(2023, 6, 25)
  },
  {
    name: 'Admin Historical Request 3',
    budget: 80.00,
    comment: 'Historical request from late 2023',
    created_at: Time.new(2023, 11, 5),
    target_date: Time.new(2023, 11, 20)
  },
  {
    name: 'Admin Historical Request 4',
    budget: 95.00,
    comment: 'Historical request from early 2024',
    created_at: Time.new(2024, 2, 12),
    target_date: Time.new(2024, 2, 28)
  },
  {
    name: 'Admin Recent Request 5',
    budget: 110.00,
    comment: 'Recent request from 2024',
    created_at: Time.new(2024, 6, 1),
    target_date: Time.new(2024, 6, 15)
  }
]

admin_historical_requests.each do |req_data|
  req = Request.new(
    user: admin,
    name: req_data[:name],
    budget: req_data[:budget],
    comment: req_data[:comment],
    target_date: req_data[:target_date],
    created_at: req_data[:created_at],
    updated_at: req_data[:created_at]
  )

  req.stl_file.attach(
    io: stl_file_path,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  req.save(validate: false)

  stl_file_path.rewind
end

user1_historical_requests = [
  {
    name: 'User Historical Request 1',
    budget: 45.00,
    comment: 'Historical request from early 2023',
    created_at: Time.new(2023, 2, 5),
    target_date: Time.new(2023, 2, 20)
  },
  {
    name: 'User Historical Request 2',
    budget: 60.00,
    comment: 'Historical request from mid 2023',
    created_at: Time.new(2023, 5, 18),
    target_date: Time.new(2023, 6, 2)
  },
  {
    name: 'User Historical Request 3',
    budget: 75.00,
    comment: 'Historical request from late 2023',
    created_at: Time.new(2023, 10, 12),
    target_date: Time.new(2023, 10, 28)
  },
  {
    name: 'User Historical Request 4',
    budget: 90.00,
    comment: 'Historical request from early 2024',
    created_at: Time.new(2024, 3, 8),
    target_date: Time.new(2024, 3, 25)
  },
  {
    name: 'User Recent Request 5',
    budget: 105.00,
    comment: 'Recent request from 2024',
    created_at: Time.new(2024, 7, 5),
    target_date: Time.new(2024, 7, 20)
  },
  {
    name: 'Free Historical Request',
    budget: 0.00,
    comment: 'Historical free request',
    created_at: Time.new(2023, 8, 15),
    target_date: Time.new(2023, 9, 1)
  },
  {
    name: 'Unanswered Historical Request',
    budget: 120.00,
    comment: 'Historical request with no offers',
    created_at: Time.new(2023, 9, 10),
    target_date: Time.new(2023, 9, 25)
  }
]

user1_historical_requests.each do |req_data|
  req = Request.new(
    user: user1,
    name: req_data[:name],
    budget: req_data[:budget],
    comment: req_data[:comment],
    target_date: req_data[:target_date],
    created_at: req_data[:created_at],
    updated_at: req_data[:created_at]
  )

  req.stl_file.attach(
    io: stl_file_path,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  req.save(validate: false)

  stl_file_path.rewind
end

3.times do |i|
  req = Request.create(
    user: admin,
    name: "Admin Current Request #{i + 1}",
    budget: (i + 1) * 25.00,
    comment: 'This is a current request from admin.',
    target_date: Time.now + (i + 5).days
  )

  req.stl_file.attach(
    io: stl_file_path,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )
  req.save

  stl_file_path.rewind
end

3.times do |i|
  req = Request.create(
    user: user1,
    name: "User Current Request #{i + 1}",
    budget: (i + 1) * 20.00,
    comment: 'This is a current request from user.',
    target_date: Time.now + (i + 10).days
  )

  req.stl_file.attach(
    io: stl_file_path,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )
  req.save
  stl_file_path.rewind
end

Request.all
Color.all
Filament.all
Printer.all

specific_preset_requests = [
  { request_id: 1, color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.08 },
  { request_id: 2, color_id: 2, filament_id: 2, printer_id: 2, print_quality: 0.12 },
  { request_id: 3, color_id: 3, filament_id: 3, printer_id: 3, print_quality: 0.16 },
  { request_id: 4, color_id: 4, filament_id: 4, printer_id: 4, print_quality: 0.20 },

  { request_id: 6, color_id: 1, filament_id: 1, printer_id: 6, print_quality: 0.08 },
  { request_id: 7, color_id: 2, filament_id: 2, printer_id: 7, print_quality: 0.12 },
  { request_id: 8, color_id: 3, filament_id: 3, printer_id: 8, print_quality: 0.16 },
  { request_id: 9, color_id: 4, filament_id: 4, printer_id: 9, print_quality: 0.20 }
]

specific_preset_requests.each do |pr_data|
  request = Request.find(pr_data[:request_id])

  PresetRequest.create!(
    request: request,
    color_id: pr_data[:color_id],
    filament_id: pr_data[:filament_id],
    printer_id: pr_data[:printer_id],
    print_quality: pr_data[:print_quality]
  )
end

user2 = User.find_by(username: 'ccc')

user2_requests = [
  {
    name: 'User2 Request',
    budget: 50.00,
    comment: 'User2 request 1',
    target_date: Time.now + 10.days
  },
  {
    name: 'User2 Request',
    budget: 75.00,
    comment: 'User2 request 2',
    target_date: Time.now + 15.days
}
]

user2_requests.each do |req_data|
  req = Request.new(
    user: user2,
    name: req_data[:name],
    budget: req_data[:budget],
    comment: req_data[:comment],
    target_date: req_data[:target_date]
  )

  req.stl_file.attach(
    io: stl_file_path,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )
  req.save

  stl_file_path.rewind
end
