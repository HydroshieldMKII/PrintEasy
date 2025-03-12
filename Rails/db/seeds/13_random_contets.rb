# frozen_string_literal: true

CONFIG = {
  start_date: Date.new(2023, 1, 1),
  end_date: Date.today,
  contests_per_month: 1,
  min_submissions_per_contest: 2,
  max_submissions_per_contest: 5,
  min_likes_per_submission: 0,
  max_likes_per_submission: 3
}.freeze

ruby_stl = File.open(Rails.root.join('db/seeds/files/RUBY13.stl'))
available_images = [
  File.open(Rails.root.join('db/seeds/files/ruby.jpg')),
  File.open(Rails.root.join('db/seeds/files/red_skeleton.jpg')),
  File.open(Rails.root.join('db/seeds/files/dragon.jpg'))
]

# Création des utilisateurs
users = []

# Création de l'admin
admin = User.create!(
  username: 'aaadmin2',
  password: 'adminadmin',
  password_confirmation: 'adminadmin',
  country_id: rand(1..15),
  is_admin: true
)
admin.profile_picture.attach(
  io: File.open(Rails.root.join('db/seeds/files/ruby.jpg')),
  filename: 'ruby.jpg',
  content_type: 'image/jpg'
)
users << admin

# Création de 9 utilisateurs réguliers
9.times do |i|
  username = ('a'..'z').to_a.sample(3).join + i.to_s
  user = User.create!(
    username: username,
    password: 'password',
    password_confirmation: 'password',
    country_id: rand(1..15),
    is_admin: false
  )

  # Attacher une image de profil aléatoire
  profile_img = available_images.sample
  profile_img.rewind
  user.profile_picture.attach(
    io: profile_img,
    filename: "#{username}.jpg",
    content_type: 'image/jpg'
  )

  users << user
end

contest_themes = [
  { theme: 'Art abstrait 3D', description: 'Exprimez-vous en 3D !' },
  { theme: 'Jeux vidéo', description: 'Reproduisez vos héros préférés !' },
  { theme: 'Décoration', description: 'Apportez une touche unique à votre intérieur !' },
  { theme: 'Animaux fantastiques', description: 'Créez des créatures imaginaires !' },
  { theme: 'Architecture futuriste', description: 'Imaginez les bâtiments de demain !' }
]

submission_ideas = [
  { name: 'Dragon sculpté', description: 'Un dragon texturé !' },
  { name: 'Vase fractal', description: 'Un vase complexe en fractales.' },
  { name: 'Support de téléphone', description: 'Un support ergonomique.' },
  { name: 'Figurine héroïque', description: "Un personnage en pose d'action." },
  { name: 'Lampe design', description: 'Un éclairage unique et élégant.' },
  { name: 'Porte-clés personnalisé', description: 'Un accessoire pratique et joli.' },
  { name: 'Bijou imprimable', description: 'Un ornement élégant et raffiné.' }
]

date = [CONFIG[:start_date], Date.today].min.beginning_of_month
end_date = CONFIG[:end_date].end_of_month

while date <= end_date
  CONFIG[:contests_per_month].times do |i|
    start_at = [date + (i * 15).days, Date.today + 1.day].min
    end_at = [start_at + 14.days, Date.today + 30.days].min

    theme_data = contest_themes.sample
    # Cette limite définit combien de soumissions par utilisateur sont autorisées
    submission_limit = rand(CONFIG[:min_submissions_per_contest]..CONFIG[:max_submissions_per_contest])
    theme = "#{theme_data[:theme]} #{date.strftime('%b %Y')} ##{i + 1}"[0..29]

    contest = Contest.create(
      theme: theme,
      description: theme_data[:description],
      submission_limit: submission_limit, # Nombre de soumissions maximum par utilisateur
      start_at: start_at,
      end_at: end_at
    )

    image_file = available_images.sample
    image_file.rewind
    contest.image.attach(
      io: image_file,
      filename: "contest-#{contest.id}.jpg",
      content_type: 'image/jpg'
    )

    contest.save(validate: false)

    submissions = []

    # Pour chaque utilisateur, créer un nombre aléatoire de soumissions
    # (jusqu'à la limite par utilisateur)
    users.each do |user|
      # Nombre aléatoire de soumissions pour cet utilisateur, en respectant la limite
      num_submissions = rand(0..submission_limit)

      num_submissions.times do
        idea = submission_ideas.sample

        submission = Submission.new(
          name: "#{idea[:name]} - #{date.strftime('%b %Y')}"[0..29],
          description: idea[:description],
          user: user,
          contest: contest
        )

        ruby_stl.rewind
        submission.stl.attach(
          io: ruby_stl,
          filename: "submission-#{submission.name.parameterize}.stl",
          content_type: 'model/stl'
        )
        image_file = available_images.sample
        image_file.rewind
        submission.image.attach(
          io: image_file,
          filename: "submission-#{submission.name.parameterize}.jpg",
          content_type: 'image/jpg'
        )

        submission.save!(validate: false)
        submissions << submission
      end
    end

    # Attribution des likes
    submissions.each do |submission|
      likers = users.reject do |u|
        u == submission.user
      end.sample(rand(CONFIG[:min_likes_per_submission]..CONFIG[:max_likes_per_submission]))
      likers.each { |liker| Like.create!(user: liker, submission: submission) }
    end
  end

  date = date.next_month
end

ruby_stl.close
available_images.each(&:close)
puts 'Génération terminée !'
