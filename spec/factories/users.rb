# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    username { Faker::Internet.username(specifier: 5..15) }
    display_name { Faker::Name.name }
    guest { false }

    trait :guest do
      guest { true }
      email { "guest_#{SecureRandom.hex(8)}@example.com" }
      username { "guest_#{SecureRandom.hex(8)}" }
    end

    trait :with_discord do
      discord_id { Faker::Number.number(digits: 18).to_s }
      discord_username { Faker::Internet.username }
      discord_discriminator { Faker::Number.number(digits: 4).to_s.rjust(4, '0') }
    end
  end
end
