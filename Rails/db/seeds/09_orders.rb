# frozen_string_literal: true

admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

Current.user = admin

user1.offers.each_with_index do |offer, i|
  Order.create!(offer: offer) if i.even?
end

Current.user = user1

admin.offers.each_with_index do |offer, i|
  Order.create!(offer: offer) if i.even?
end
