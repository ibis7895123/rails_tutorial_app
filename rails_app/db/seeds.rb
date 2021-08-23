# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 最初のユーザーを作成
User.create!(
  name: 'Example User',
  email: 'example@railstutorial.org',
  password: 'password',
  password_confirmation: 'password',
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

# その他99人のユーザーを作成
99.times do |time|
  name = Faker::Name.name
  email = "example-#{time + 1}@railstutorial.org"
  password = 'password'
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now
  )
end

# 最初に作られた6人のユーザーを取得
users = User.order(:created_at).take(6)

# 6人のユーザーごとに50投稿作成
# タイムラインが1人のユーザーにならないように、ループ順を投稿→ユーザーにしている
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end
