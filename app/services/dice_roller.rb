# frozen_string_literal: true

class DiceRoller
  class InvalidDiceExpression < StandardError; end

  # Rolls a d20
  def roll_d20
    rand(1..20)
  end

  # Rolls any die type (e.g., d6, d8, d10, d12, d20)
  def roll_die(sides)
    rand(1..sides)
  end

  # Rolls multiple dice and returns array of results
  def roll_dice(count, sides)
    Array.new(count) { roll_die(sides) }
  end

  # Parse and roll a dice expression like "2d6+3" or "1d20"
  # Returns hash with detailed breakdown
  def parse_and_roll(expression)
    raise InvalidDiceExpression, "Invalid expression: #{expression}" unless valid_expression?(expression)

    parts = parse_expression(expression)
    results = roll_expression_parts(parts)

    {
      expression: expression,
      parts: parts,
      results: results,
      total: calculate_total(results)
    }
  end

  # Roll with advantage (take higher of two d20s)
  def roll_with_advantage
    dice = [roll_d20, roll_d20]
    {
      dice_results: dice,
      result: dice.max,
      highlighted_die: dice.index(dice.max)
    }
  end

  # Roll with disadvantage (take lower of two d20s)
  def roll_with_disadvantage
    dice = [roll_d20, roll_d20]
    {
      dice_results: dice,
      result: dice.min,
      highlighted_die: dice.index(dice.min)
    }
  end

  # Validates a dice expression
  def valid_expression?(expression)
    return false if expression.blank?

    expr = expression.gsub(/\s+/, '')
    pattern = /^(\d+d\d+([+-]\d+d\d+)*([+-]\d+)?)$/i
    expr.match?(pattern)
  end

  private

  def parse_expression(expression)
    expr = expression.gsub(/\s+/, '')
    parts = []

    tokens = expr.scan(/[+-]?[^+-]+/)

    tokens.each do |token|
      if token.match?(/(\d+)d(\d+)/i)
        match = token.match(/([+-])?(\d+)d(\d+)/i)
        parts << {
          type: :dice,
          operator: match[1] || '+',
          count: match[2].to_i,
          sides: match[3].to_i,
          notation: "#{match[2]}d#{match[3]}"
        }
      elsif token.match?(/[+-]?\d+/)
        match = token.match(/([+-])?(\d+)/)
        parts << {
          type: :modifier,
          operator: match[1] || '+',
          value: match[2].to_i
        }
      end
    end

    parts
  end

  def roll_expression_parts(parts)
    parts.map do |part|
      if part[:type] == :dice
        dice_results = roll_dice(part[:count], part[:sides])
        {
          type: :dice,
          notation: part[:notation],
          operator: part[:operator],
          rolls: dice_results,
          sum: dice_results.sum
        }
      else
        {
          type: :modifier,
          operator: part[:operator],
          value: part[:value]
        }
      end
    end
  end

  def calculate_total(results)
    total = 0
    results.each do |result|
      value = result[:type] == :dice ? result[:sum] : result[:value]
      total += result[:operator] == '-' ? -value : value
    end
    total
  end
end
