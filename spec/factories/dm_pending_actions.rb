# frozen_string_literal: true

FactoryBot.define do
  factory :dm_pending_action do
    association :terminal_session
    association :user
    character { nil }

    tool_name { 'level_up' }
    parameters { { class: 'Fighter', level: 2 } }
    description { 'Level up to Fighter 2' }
    dm_reasoning { 'Character has enough XP to advance' }
    status { 'pending' }
    expires_at { 5.minutes.from_now }
  end
end
