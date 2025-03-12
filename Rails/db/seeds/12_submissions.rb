admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')
user2 = User.find_by(username: 'bbb')

contest1 = Contest.find_by(theme: 'Best 3D Printed Art')
contest3 = Contest.find_by(theme: 'Best 3D Printed Jewelry')
contest5 = Contest.find_by(theme: 'Best 3D Printed Fashion')
contest7 = Contest.find_by(theme: 'Best 3D Printed Tools')
contest8 = Contest.find_by(theme: 'Best 3D Printed Medical')
contest10 = Contest.find_by(theme: 'Best 3D Printed Food')

ruby_stl = File.open(Rails.root.join('db/seeds/files/RUBY13.stl'))

ruby_image = File.open(Rails.root.join('db/seeds/files/ruby.jpg'))
red_skeleton = File.open(Rails.root.join('db/seeds/files/red_skeleton.jpg'))
dragon = File.open(Rails.root.join('db/seeds/files/dragon.jpg'))

# Create Submissions
submission1 = Submission.new(
  name: '3D Dragon',
  description: 'A detailed dragon model.',
  user: admin,
  contest: contest1
)

submission1.stl.attach(
  io: File.open(Rails.root.join('db/seeds/files/RUBY13.stl')),
  filename: 'RUBY13.stl',
  content_type: 'application/sla'
)

submission1.image.attach(
  io: red_skeleton,
  filename: 'red_skeleton.jpg',
  content_type: 'image/jpg'
)

submission1.save(validate: false)

submission2 = Submission.new(
  name: 'Space Shuttle',
  description: 'NASA space shuttle model.',
  user: user1,
  contest: contest1
)

ruby_stl.rewind

submission2.stl.attach(
  io: ruby_stl,
  filename: 'RUBY13.stl',
  content_type: 'application/sla'
)

submission2.image.attach(
  io: dragon,
  filename: 'dragon.jpg',
  content_type: 'image/jpg'
)

submission2.save(validate: false)

submission3 = Submission.new(
  name: '3D Printed Toy',
  description: 'A toy model.',
  user: admin,
  contest: contest1
)

ruby_stl.rewind

submission3.stl.attach(
  io: ruby_stl,
  filename: 'RUBY13.stl',
  content_type: 'application/sla'
)

ruby_image.rewind

submission3.image.attach(
  io: ruby_image,
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)

submission3.save

5.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: user2,
    contest: contest1
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)
end

2.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: admin,
    contest: contest3
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)

  Like.create!(user: user1, submission: submission)
end

3.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: user1,
    contest: contest5
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)

  Like.create!(user: user1, submission: submission)
  Like.create!(user: user2, submission: submission)
end

4.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: user1,
    contest: contest7
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)

  Like.create!(user: user1, submission: submission)
  Like.create!(user: user2, submission: submission)
  Like.create!(user: admin, submission: submission)
end

5.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: user1,
    contest: contest8
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)

  Like.create!(user: user1, submission: submission)
  Like.create!(user: user2, submission: submission)
end

5.times do |i|
  submission = Submission.new(
    name: "Submission #{i + 1}",
    description: "Description for submission #{i + 1}.",
    user: user1,
    contest: contest10
  )

  ruby_stl.rewind

  submission.stl.attach(
    io: ruby_stl,
    filename: 'RUBY13.stl',
    content_type: 'application/sla'
  )

  red_skeleton.rewind

  submission.image.attach(
    io: red_skeleton,
    filename: 'red_skeleton.jpg',
    content_type: 'image/jpg'
  )

  submission.save(validate: false)

  Like.create!(user: user1, submission: submission)
  Like.create!(user: user2, submission: submission)
end

Like.create!(user: user1, submission: submission1)
Like.create!(user: user1, submission: submission2)