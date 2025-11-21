# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Try to find user from session
      if verified_user = User.find_by(id: cookies.encrypted[:user_id])
        verified_user
      # Or from Devise session
      elsif verified_user = env['warden']&.user
        verified_user
      # Or create/find guest user for demo
      elsif cookies[:guest_user_id]
        User.find_by(id: cookies[:guest_user_id]) || create_guest_user
      else
        create_guest_user
      end
    end

    def create_guest_user
      guest = User.create!(
        email: "guest_#{SecureRandom.hex(8)}@terminal-dnd.local",
        password: SecureRandom.hex(16),
        guest: true
      )
      cookies[:guest_user_id] = { value: guest.id, expires: 1.week.from_now }
      guest
    rescue ActiveRecord::RecordInvalid
      reject_unauthorized_connection
    end
  end
end
