# frozen_string_literal: true

# Main seed file for Terminal D&D
# Run with: rails db:seed

puts '🎲 Seeding Terminal D&D database...'
puts

# Load seed files in order
seed_files = %w[
  races
  classes
  backgrounds
]

seed_files.each do |seed_file|
  seed_path = Rails.root.join('db', 'seeds', "#{seed_file}.rb")
  if File.exist?(seed_path)
    load seed_path
    puts
  else
    puts "⚠️  Seed file not found: #{seed_file}.rb"
  end
end

puts '✅ Seeding complete!'
puts
puts "Summary:"
puts "  - Races: #{Race.count rescue 'N/A'}"
puts "  - Classes: #{CharacterClass.count rescue 'N/A'}"
puts "  - Backgrounds: #{Background.count rescue 'N/A'}"
