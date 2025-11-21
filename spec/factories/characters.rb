# frozen_string_literal: true

FactoryBot.define do
  factory :character do
    user
    name { Faker::Fantasy::Tolkien.character }
    level { 1 }
    experience { 0 }

    # Ability scores
    strength { rand(8..18) }
    dexterity { rand(8..18) }
    constitution { rand(8..18) }
    intelligence { rand(8..18) }
    wisdom { rand(8..18) }
    charisma { rand(8..18) }

    # Hit points
    max_hp { 10 + rand(1..8) }
    current_hp { max_hp }
    hit_points_max { max_hp }
    hit_points_current { current_hp }
    temporary_hp { 0 }
    temporary_hit_points { 0 }

    # Combat stats
    armor_class { 10 + ((dexterity - 10) / 2) }
    initiative_bonus { (dexterity - 10) / 2 }
    speed { 30 }

    # Associations are optional
    race { nil }
    character_class { nil }
    background { nil }

    trait :high_level do
      level { rand(5..10) }
      experience { [6500, 14000, 23000, 34000, 48000, 64000].sample }
    end
  end
end
