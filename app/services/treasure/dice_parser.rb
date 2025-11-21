# frozen_string_literal: true

module Treasure
  # Parses and rolls dice expressions like "2d6+3" or "1d20"
  class DiceParser
    class InvalidDiceExpression < StandardError; end

    # Parse and roll a dice expression
    # @param expression [String] Dice expression like "2d6+3"
    # @return [Hash] { total: Integer, rolls: Array, modifier: Integer, expression: String }
    def self.roll(expression)
      new(expression).roll
    end

    def initialize(expression)
      @expression = expression.to_s.strip.downcase
    end

    def roll
      parsed = parse_expression
      rolls = roll_dice(parsed[:count], parsed[:sides])
      total = rolls.sum + parsed[:modifier]

      {
        total: total,
        rolls: rolls,
        modifier: parsed[:modifier],
        expression: @expression,
        breakdown: build_breakdown(rolls, parsed[:modifier])
      }
    end

    private

    def parse_expression
      # Match patterns like: 2d6, 2d6+3, 2d6-1, d20, d20+5
      match = @expression.match(/^(\d+)?d(\d+)([+-]\d+)?$/)

      raise InvalidDiceExpression, "Invalid dice expression: #{@expression}" unless match

      count = (match[1] || 1).to_i
      sides = match[2].to_i
      modifier = (match[3] || 0).to_i

      validate_dice_parameters(count, sides)

      { count: count, sides: sides, modifier: modifier }
    end

    def validate_dice_parameters(count, sides)
      raise InvalidDiceExpression, "Dice count must be positive" if count <= 0
      raise InvalidDiceExpression, "Dice must have at least 2 sides" if sides < 2
      raise InvalidDiceExpression, "Cannot roll more than 100 dice at once" if count > 100
      raise InvalidDiceExpression, "Dice cannot have more than 100 sides" if sides > 100
    end

    def roll_dice(count, sides)
      Array.new(count) { rand(1..sides) }
    end

    def build_breakdown(rolls, modifier)
      parts = []
      parts << rolls.join(' + ') if rolls.any?
      parts << modifier.to_s if modifier != 0

      rolls_text = rolls.join(', ')
      modifier_text = modifier.zero? ? '' : " #{modifier >= 0 ? '+' : ''}#{modifier}"

      "[#{rolls_text}]#{modifier_text}"
    end
  end
end
