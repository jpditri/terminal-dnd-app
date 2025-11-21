# frozen_string_literal: true

FactoryBot.define do
  factory :terminal_session do
    user
    title { "Adventure in #{Faker::Fantasy::Tolkien.location}" }
    mode { 'exploration' }
    active { true }
    map_render_mode { 'ascii' }
    show_map_panel { true }
    command_history { [] }
    settings { {} }

    trait :with_character do
      character
    end

    trait :combat_mode do
      mode { 'combat' }
    end

    trait :roleplay_mode do
      mode { 'roleplay' }
    end

    trait :inactive do
      active { false }
    end

    trait :with_discord do
      discord_channel_id { Faker::Number.number(digits: 18).to_s }
      discord_guild_id { Faker::Number.number(digits: 18).to_s }
    end
  end
end
