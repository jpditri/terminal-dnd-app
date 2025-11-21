# frozen_string_literal: true

module Multiplayer
  class DiceBroadcaster
    attr_reader :dice_roller

    def initialize(dice_roller: DiceRoller.new)
      @dice_roller = dice_roller
    end


    def broadcast_roll(params)
      # TODO: Implement
    end

    def reveal_hidden_roll(roll_id)
      # TODO: Implement
    end

    def get_roll_history(limit: 50, user_id: nil, roll_type: nil)
      # TODO: Implement
    end

    def broadcast_batch(rolls_array)
      # TODO: Implement
    end
  end
end