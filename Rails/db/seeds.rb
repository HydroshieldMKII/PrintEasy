# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create countries
[
    { name: 'United States', id: 1 },
    { name: 'Canada', id: 2 },
    { name: 'France', id: 3 },
    { name: 'Germany', id: 4 },
    { name: 'Italy', id: 5 },
    { name: 'Spain', id: 6 },
    { name: 'United Kingdom', id: 7 },
    { name: 'Australia', id: 8 },
    { name: 'Brazil', id: 9 },
    { name: 'China', id: 10 },
    { name: 'India', id: 11 },
    { name: 'Japan', id: 12 },
    { name: 'Mexico', id: 13 },
    { name: 'Russia', id: 14 },
    { name: 'South Africa', id: 15 }
].each do |country|
    Country.create(id: country[:id], name: country[:name])
end