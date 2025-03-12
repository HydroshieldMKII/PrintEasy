# frozen_string_literal: true

ruby_image = File.open(Rails.root.join('db/seeds/files/ruby.jpg'))
darius_image = File.open(Rails.root.join('db/seeds/files/DariusSlayJunior.jpg'))
admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

Current.user = admin
user1.offers.each_with_index do |offer, _i|
  linked_order = offer.order
  next unless linked_order

  if linked_order.order_status.last.status.name == 'Shipped' && rand(1..2) == 1
    o = OrderStatus.create!(
      order: linked_order,
      status: Status.find_by(name: 'Arrived')
    )
    o.image.attach(
      io: ruby_image,
      filename: 'ruby.jpg',
      content_type: 'image/jpg'
    )
    o.save
    ruby_image.rewind

    r1 = Review.create!(
      order: linked_order,
      rating: rand(1..5),
      user: admin,
      description: 'imagine a great review here',
      title: 'Great Review'
    )
    r1.images.attach(
      [
        { io: ruby_image, filename: 'ruby.jpg', content_type: 'image/jpg' },
        { io: darius_image, filename: 'DariusSlayJunior.jpg', content_type: 'image/jpg' }
      ]
    )
    ruby_image.rewind
    darius_image.rewind
    r1.save
  end

  next unless linked_order.order_status.last.status.name == 'Accepted' && rand(1..2) == 1

  o = OrderStatus.create!(
    order: linked_order,
    status: Status.find_by(name: 'Cancelled')
  )
  o.image.attach(
    io: ruby_image,
    filename: 'ruby.jpg',
    content_type: 'image/jpg'
  )
  o.save
  ruby_image.rewind

  r1 = Review.create!(
    order: linked_order,
    rating: rand(1..5),
    user: admin,
    description: 'imagine a great review here',
    title: 'Great Review'
  )
  r1.images.attach(
    [
      { io: ruby_image, filename: 'ruby.jpg', content_type: 'image/jpg' },
      { io: darius_image, filename: 'DariusSlayJunior.jpg', content_type: 'image/jpg' }
    ]
  )
  ruby_image.rewind
  darius_image.rewind
  r1.save
end

Current.user = user1
admin.offers.each_with_index do |offer, _i|
  linked_order = offer.order
  next unless linked_order

  if linked_order.order_status.last.status.name == 'Shipped' && rand(1..2) == 1
    o = OrderStatus.create!(
      order: linked_order,
      status: Status.find_by(name: 'Arrived')
    )
    o.image.attach(
      io: ruby_image,
      filename: 'ruby.jpg',
      content_type: 'image/jpg'
    )
    o.save
    ruby_image.rewind

    r1 = Review.create!(
      order: linked_order,
      rating: rand(1..5),
      user: user1,
      description: 'imagine a great review here',
      title: 'Great Review'
    )
    r1.images.attach(
      [
        { io: ruby_image, filename: 'ruby.jpg', content_type: 'image/jpg' },
        { io: darius_image, filename: 'DariusSlayJunior.jpg', content_type: 'image/jpg' }
      ]
    )
    ruby_image.rewind
    darius_image.rewind
    r1.save
  end

  next unless linked_order.order_status.last.status.name == 'Accepted' && rand(1..2) == 1

  o = OrderStatus.create!(
    order: linked_order,
    status: Status.find_by(name: 'Cancelled')
  )
  o.image.attach(
    io: ruby_image,
    filename: 'ruby.jpg',
    content_type: 'image/jpg'
  )
  o.save
  ruby_image.rewind

  r1 = Review.create!(
    order: linked_order,
    rating: rand(1..5),
    user: user1,
    description: 'imagine a great review here',
    title: 'Great Review'
  )
  r1.images.attach(
    [
      { io: ruby_image, filename: 'ruby.jpg', content_type: 'image/jpg' },
      { io: darius_image, filename: 'DariusSlayJunior.jpg', content_type: 'image/jpg' }
    ]
  )
  ruby_image.rewind
  darius_image.rewind
  r1.save
end
