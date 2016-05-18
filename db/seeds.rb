admin = User.create(email: "alex+admin@commercekitchen.com", password: "asdfasdf", admin: true, confirmed_at: Time.zone.now)
puts "Admin User Created - Username: #{admin.email}, Password: asdfasdf"

user = User.create(email: "alex+user@commercekitchen.com", password: "asdfasdf", confirmed_at: Time.zone.now)
puts "Regular User Created - Username: #{user.email}, Password: asdfasdf"
