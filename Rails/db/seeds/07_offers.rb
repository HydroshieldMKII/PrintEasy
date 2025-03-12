# frozen_string_literal: true

admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

admin_printer_users = PrinterUser.where(user: admin).to_a
user1_printer_users = PrinterUser.where(user: user1).to_a

admin_requests = Request.where(user: admin).to_a
user1_requests = Request.where(user: user1).to_a

# Admin making offers on user1's requests
admin_historical_offers = [
  {
    request_id: user1_requests[0].id,
    printer_user_id: admin_printer_users[0].id,
    color_id: 1,
    filament_id: 1,
    price: 42.50,
    print_quality: 0.08,
    target_date: Time.new(2023, 2, 19).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 2, 7),
    updated_at: Time.new(2023, 2, 7)
  },
  {
    request_id: user1_requests[1].id,
    printer_user_id: admin_printer_users[1].id,
    color_id: 3,
    filament_id: 3,
    price: 58.75,
    print_quality: 0.16,
    target_date: Time.new(2023, 6, 1).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 5, 20),
    updated_at: Time.new(2023, 5, 20)
  },
  {
    request_id: user1_requests[2].id,
    printer_user_id: admin_printer_users[2].id,
    color_id: 3,
    filament_id: 3,
    price: 70.25,
    print_quality: 0.2,
    target_date: Time.new(2023, 10, 27).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 10, 14),
    updated_at: Time.new(2023, 10, 14)
  },
  {
    request_id: user1_requests[3].id,
    printer_user_id: admin_printer_users[3].id,
    color_id: 7,
    filament_id: 1,
    price: 85.00,
    print_quality: 0.16,
    target_date: Time.new(2024, 3, 24).strftime('%Y-%m-%d'),
    created_at: Time.new(2024, 3, 10), 
    updated_at: Time.new(2024, 3, 10)
  },
  {
    request_id: user1_requests[4].id,
    printer_user_id: admin_printer_users[4].id,
    color_id: 5,
    filament_id: 5,
    price: 100.50,
    print_quality: 0.08,
    target_date: Time.new(2024, 7, 19).strftime('%Y-%m-%d'),
    created_at: Time.new(2024, 7, 7), 
    updated_at: Time.new(2024, 7, 7)
  }
]

# User1 making offers on admin's requests
user1_historical_offers = [
  {
    request_id: admin_requests[0].id,
    printer_user_id: user1_printer_users[0].id,
    color_id: 2,
    filament_id: 2,
    price: 48.50,
    print_quality: 0.12,
    target_date: Time.new(2023, 1, 29).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 1, 17), 
    updated_at: Time.new(2023, 1, 17)
  },
  {
    request_id: admin_requests[1].id,
    printer_user_id: user1_printer_users[1].id,
    color_id: 4,
    filament_id: 4,
    price: 62.25,
    print_quality: 0.2,
    target_date: Time.new(2023, 6, 24).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 6, 12), 
    updated_at: Time.new(2023, 6, 12)
  },
  {
    request_id: admin_requests[2].id,
    printer_user_id: user1_printer_users[2].id,
    color_id: 3,
    filament_id: 3,
    price: 78.50,
    print_quality: 0.2,
    target_date: Time.new(2023, 11, 19).strftime('%Y-%m-%d'),
    created_at: Time.new(2023, 11, 7), 
    updated_at: Time.new(2023, 11, 7)
  },
  {
    request_id: admin_requests[3].id,
    printer_user_id: user1_printer_users[3].id,
    color_id: 6,
    filament_id: 6,
    price: 92.75,
    print_quality: 0.12,
    target_date: Time.new(2024, 2, 27).strftime('%Y-%m-%d'),
    created_at: Time.new(2024, 2, 14), 
    updated_at: Time.new(2024, 2, 14)
  },
  {
    request_id: admin_requests[4].id,
    printer_user_id: user1_printer_users[4].id,
    color_id: 10,
    filament_id: 4,
    price: 108.50,
    print_quality: 0.12,
    target_date: Time.new(2024, 6, 14).strftime('%Y-%m-%d'),
    created_at: Time.new(2024, 6, 3), 
    updated_at: Time.new(2024, 6, 3)
  }
]

Current.user = admin 
admin_historical_offers.each do |offer_data|
  offer = Offer.new(offer_data)
  offer.save(validate: false)
end

Current.user = user1
user1_historical_offers.each do |offer_data|
  offer = Offer.new(offer_data)
  offer.save(validate: false)
end

admin_recent_requests = Request.where(user: admin)
                               .where("created_at > ?", Date.today - 1.month)
                               .limit(3)
                               .to_a

user1_recent_requests = Request.where(user: user1)
                               .where("created_at > ?", Date.today - 1.month)
                               .limit(3)
                               .to_a

Current.user = admin
admin_current_offers = [
  {
    request_id: user1_recent_requests[0].id, 
    printer_user_id: admin_printer_users[0].id,
    color_id: 1,
    filament_id: 1,
    price: 35.50,
    print_quality: 0.08,
    target_date: (Date.today + 7.days).strftime('%Y-%m-%d')
  },
  {
    request_id: user1_recent_requests[1].id,
    printer_user_id: admin_printer_users[1].id,
    color_id: 2,
    filament_id: 2,
    price: 42.75,
    print_quality: 0.15,
    target_date: (Date.today + 8.days).strftime('%Y-%m-%d')
  },
  {
    request_id: user1_recent_requests[2].id,
    printer_user_id: admin_printer_users[2].id,
    color_id: 9,
    filament_id: 3,
    price: 28.99,
    print_quality: 0.08,
    target_date: (Date.today + 6.days).strftime('%Y-%m-%d')
  }
]

admin_current_offers.each do |offer_data|
  offer = Offer.new(offer_data)
  offer.save
end

Current.user = user1
user1_current_offers = [
  {
    request_id: admin_recent_requests[0].id,
    printer_user_id: user1_printer_users[0].id,
    color_id: 8,
    filament_id: 2,
    price: 29.99,
    print_quality: 0.2,
    target_date: (Date.today + 7.days).strftime('%Y-%m-%d')
  },
  {
    request_id: admin_recent_requests[1].id,
    printer_user_id: user1_printer_users[1].id,
    color_id: 2,
    filament_id: 2,
    price: 45.50,
    print_quality: 0.12,
    target_date: (Date.today + 9.days).strftime('%Y-%m-%d')
  },
  {
    request_id: admin_recent_requests[2].id,
    printer_user_id: user1_printer_users[2].id,
    color_id: 3,
    filament_id: 3,
    price: 52.75,
    print_quality: 0.1,
    target_date: (Date.today + 10.days).strftime('%Y-%m-%d')
  }
]

user1_current_offers.each do |offer_data|
  offer = Offer.new(offer_data)
  offer.save
end