# Ensure WorldServices module is loaded
# This prevents "uninitialized constant" errors

Rails.application.config.to_prepare do
  # Eager load WorldServices classes
  require_dependency 'world_services/state_tracker' if Rails.env.development?
  require_dependency 'world_services/faction_reputation_manager' if Rails.env.development?
end
