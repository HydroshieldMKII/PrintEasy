admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

Current.user = admin

user1.offers.each_with_index do |offer, i|
  if i % 2 == 0
    Order.create!(offer: offer)
  end
end

Current.user = user1

admin.offers.each_with_index do |offer, i|
  if i % 2 == 0
    Order.create!(offer: offer)
  end
end