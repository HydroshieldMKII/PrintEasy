# frozen_string_literal: true

ruby_image = File.open(Rails.root.join('db/seeds/files/ruby.jpg'))

# Create Contests
contest1 = Contest.new(
  theme: 'Best 3D Printed Art',
  description: 'Create and submit your best 3D printed designs.',
  submission_limit: 5,
  start_at: Time.now - 10.days,
  end_at: Time.now - 3.days
)

contest1.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)
contest1.save(validate: false)

contest2 = Contest.new(
  theme: 'Best 3D Printed Toy',
  description: 'Create and submit your best 3D printed toys.',
  submission_limit: 5,
  deleted_at: Time.now,
  start_at: Time.now - 1.days
)

ruby_image.rewind

contest2.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)
contest2.save(validate: false)

contest3 = Contest.create(
  theme: 'Best 3D Printed Jewelry',
  description: 'Create and submit your best 3D printed jewelry.',
  submission_limit: 5,
  start_at: Time.now - 20.days,
  end_at: Time.now - 10.days
)

ruby_image.rewind

contest3.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest3.save(validate: false)

contest4 = Contest.create(
  theme: 'Best 3D Printed Home Decor',
  description: 'Create and submit your best 3D printed home decor.',
  submission_limit: 5,
  deleted_at: Time.now,
  start_at: Time.now - 2.days,
  end_at: Time.now + 30.days
)

ruby_image.rewind

contest4.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest4.save(validate: false)

contest5 = Contest.create(
  theme: 'Best 3D Printed Fashion',
  submission_limit: 5,
  start_at: Time.now - 5.days,
  end_at: Time.now + 30.days
)

ruby_image.rewind

contest5.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest5.save(validate: false)

contest6 = Contest.create(
  theme: 'Best 3D Printed Gadgets',
  submission_limit: 5,
  start_at: Time.now - 10.days,
  deleted_at: Time.now
)

ruby_image.rewind

contest6.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest6.save(validate: false)

contest7 = Contest.create(
  theme: 'Best 3D Printed Tools',
  submission_limit: 5,
  start_at: Time.now - 10.days
)

ruby_image.rewind

contest7.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest7.save(validate: false)

contest8 = Contest.create(
  theme: 'Best 3D Printed Medical',
  submission_limit: 5,
  start_at: Time.now - 15.days,
  end_at: Time.now + 30.days
)

ruby_image.rewind

contest8.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest8.save(validate: false)

contest9 = Contest.create(
  theme: 'Best 3D Printed Automotive',
  submission_limit: 5,
  start_at: Time.now - 15.days,
  deleted_at: Time.now,
  end_at: Time.now + 30.days
)

ruby_image.rewind

contest9.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest9.save(validate: false)

contest10 = Contest.create(
  theme: 'Best 3D Printed Electronics',
  submission_limit: 5,
  start_at: Time.now - 15.days,
  end_at: Time.now - 10.days
)

ruby_image.rewind

contest10.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

contest10.save(validate: false)

10.times do |i|
  contest = Contest.create(
    theme: "Contest #{i + 3}",
    description: "Description for contest #{i + 3}.",
    submission_limit: 5,
    start_at: Time.now + i.days,
    end_at: Time.now + 30.days + i.days
  )

  ruby_image.rewind

  contest.image.attach(
    io: ruby_image,
    filename: 'ruby.jpg',
    content_type: 'image/jpg'
  )
  contest.save
end
