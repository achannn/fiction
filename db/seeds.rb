# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# system user (currently only used for system-generated chat messages)
if User.find_by(username: "system", email: "system@fiction.party").nil?
  user = User.new
  user.username = "system"
  user.email = "system@fiction.party"
  user.password = Rails.application.credentials.dig(:seed, :system_user_password)
  user.password_confirmation = Rails.application.credentials.dig(:seed, :system_user_password)
  user.save
end
