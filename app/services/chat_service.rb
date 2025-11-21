# frozen_string_literal: true

class ChatService
  attr_reader :user, :game_session

  def initialize(user: User.new, game_session: GameSession.new)
    @user = user
    @game_session = game_session
  end


  def create_message(content:, message_type: 'public', recipient_id: nil, character_id: nil)
    # TODO: Implement
  end

  def edit_message(message_id:, new_content:)
    # TODO: Implement
  end

  def delete_message(message_id:, is_dm: false)
    # TODO: Implement
  end

  def load_history(before_id: nil, limit: 50)
    # TODO: Implement
  end

  def search_messages(query:, user_filter: nil)
    # TODO: Implement
  end
end