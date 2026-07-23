# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

default_pm = Identity::Domain::Aggregates::Account.find_or_create_by!(email: "pm@example.com", role: :pm) do |pm|
  pm.name = "Default PM"
  pm.role = :pm
end

default_client = Identity::Domain::Aggregates::Account.find_or_create_by!(email: "client@example.com", role: :client) do |client|
  client.name = "Default Client"
  client.role = :client
end

video_types = [
  { name: "Social Cut", description: "Short-form edit for social channels", price_cents: 15_000, output_format: "mp4" },
  { name: "Highlight Reel", description: "Polished highlight package", price_cents: 25_000, output_format: "mp4" }
]

video_types.each do |attrs|
  VideoType.find_or_create_by!(name: attrs[:name]) do |video_type|
    video_type.description = attrs[:description]
    video_type.price_cents = attrs[:price_cents]
    video_type.output_format = attrs[:output_format]
  end
end

Project.find_or_create_by!(client_account: default_client, pm_account: default_pm, name: "Seed Project") do |project|
  project.raw_footage_url = "https://example.com/raw-footage.mov"
  project.status = :draft
end
