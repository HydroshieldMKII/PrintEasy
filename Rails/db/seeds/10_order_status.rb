# frozen_string_literal: true

ruby_image = File.open(Rails.root.join('db/seeds/files/ruby.jpg'))
darius_image = File.open(Rails.root.join('db/seeds/files/DariusSlayJunior.jpg'))
admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

statuses_ref = %w[Accepted Printing Printed Shipped Arrived Cancelled]
statuses = Status.all

Current.user = admin
admin.offers.each_with_index do |offer, _i|
  linked_order = offer.order
  next unless linked_order

  rand(1..4).times do |j|
    o = OrderStatus.create!(
      order: linked_order,
      status: statuses.find_by(name: statuses_ref[j])
    )
    next unless rand(1..3) == 1

    o.image.attach(
      io: ruby_image,
      filename: 'ruby.jpg',
      content_type: 'image/jpg'
    )
    o.save
    ruby_image.rewind
  end
end

Current.user = user1
user1.offers.each_with_index do |offer, _i|
  linked_order = offer.order
  next unless linked_order

  rand(1..3).times do |j|
    o = OrderStatus.create!(
      order: linked_order,
      status: statuses.find_by(name: statuses_ref[j])
    )
    next unless rand(1..3) == 1

    o.image.attach(
      io: darius_image,
      filename: 'ruby.jpg',
      content_type: 'image/jpg'
    )
    o.save
    darius_image.rewind
  end
end
