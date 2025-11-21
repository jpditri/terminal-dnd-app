# frozen_string_literal: true

module Treasure
  # Generates treasure from loot tables with weighted random selection
  class Generator
    attr_reader :loot_table, :campaign, :character

    def initialize(loot_table:, campaign:, character: nil)
      @loot_table = loot_table
      @campaign = campaign
      @character = character
    end

    # Generate treasure from the loot table
    # @return [Hash] Generated treasure data
    def generate
      return error_result('Loot table has no entries') if loot_table.loot_table_entries.empty?

      rolled_entries = roll_loot_table
      treasure_data = build_treasure_data(rolled_entries)

      # Create GeneratedTreasure record
      generated = GeneratedTreasure.create!(
        loot_table: loot_table,
        campaign: campaign,
        character: character,
        treasure_data: treasure_data,
        generated_at: Time.current
      )

      success_result(generated, treasure_data)
    end

    # Generate treasure based on challenge rating
    # @param challenge_rating [Float] CR of the encounter
    # @return [Hash] Generated treasure including gold and items
    def self.generate_by_challenge_rating(challenge_rating:, campaign:, character: nil)
      # D&D 5e DMG treasure tables by CR
      treasure = case challenge_rating
                 when 0..4
                   generate_individual_treasure_cr_0_4
                 when 5..10
                   generate_individual_treasure_cr_5_10
                 when 11..16
                   generate_individual_treasure_cr_11_16
                 else
                   generate_individual_treasure_cr_17_plus
                 end

      # Record generation
      GeneratedTreasure.create!(
        loot_table: nil,
        campaign: campaign,
        character: character,
        treasure_data: treasure,
        generated_at: Time.current
      )

      treasure
    end

    private

    def roll_loot_table
      entries = loot_table.loot_table_entries.to_a
      total_weight = entries.sum(&:weight)

      return [] if total_weight.zero?

      # Roll once from weighted table
      roll = rand(total_weight)
      cumulative_weight = 0

      entries.each do |entry|
        cumulative_weight += entry.weight
        if roll < cumulative_weight
          return [roll_entry(entry)]
        end
      end

      []
    end

    def roll_entry(entry)
      quantity = if entry.quantity_dice.present?
                   DiceParser.roll(entry.quantity_dice)[:total]
                 else
                   1
                 end

      {
        treasure_type: entry.treasure_type,
        quantity: quantity,
        item_id: entry.item_id,
        item_name: entry.item&.name,
        treasure_data: entry.treasure_data
      }
    end

    def build_treasure_data(rolled_entries)
      {
        entries: rolled_entries,
        gold: rolled_entries.select { |e| e[:treasure_type] == 'gold' }.sum { |e| e[:quantity] },
        items: rolled_entries.select { |e| e[:treasure_type] == 'item' },
        rolled_at: Time.current.iso8601
      }
    end

    def success_result(generated, treasure_data)
      {
        success: true,
        generated_treasure_id: generated.id,
        treasure: treasure_data,
        message: format_treasure_message(treasure_data)
      }
    end

    def error_result(message)
      {
        success: false,
        error: message
      }
    end

    def format_treasure_message(treasure_data)
      parts = []
      parts << "#{treasure_data[:gold]} gold pieces" if treasure_data[:gold] > 0
      parts << "#{treasure_data[:items].length} items" if treasure_data[:items].any?
      "Generated treasure: #{parts.join(', ')}"
    end

    # DMG Treasure Tables by CR (simplified version)
    def self.generate_individual_treasure_cr_0_4
      roll = rand(1..100)
      copper = silver = electrum = gold = platinum = 0

      case roll
      when 1..30
        copper = DiceParser.roll('5d6')[:total]
      when 31..60
        silver = DiceParser.roll('4d6')[:total]
      when 61..70
        electrum = DiceParser.roll('3d6')[:total]
      when 71..95
        gold = DiceParser.roll('3d6')[:total]
      when 96..100
        platinum = DiceParser.roll('1d6')[:total]
      end

      {
        copper_pieces: copper,
        silver_pieces: silver,
        electrum_pieces: electrum,
        gold_pieces: gold,
        platinum_pieces: platinum,
        total_gold_value: copper * 0.01 + silver * 0.1 + electrum * 0.5 + gold + platinum * 10,
        items: []
      }
    end

    def self.generate_individual_treasure_cr_5_10
      roll = rand(1..100)
      copper = silver = electrum = gold = platinum = 0

      case roll
      when 1..30
        copper = DiceParser.roll('4d6')[:total] * 100
        electrum = DiceParser.roll('1d6')[:total] * 10
      when 31..60
        silver = DiceParser.roll('6d6')[:total] * 10
        gold = DiceParser.roll('2d6')[:total] * 10
      when 61..70
        electrum = DiceParser.roll('3d6')[:total] * 10
        gold = DiceParser.roll('2d6')[:total] * 10
      when 71..95
        gold = DiceParser.roll('4d6')[:total] * 10
      when 96..100
        gold = DiceParser.roll('2d6')[:total] * 10
        platinum = DiceParser.roll('3d6')[:total]
      end

      {
        copper_pieces: copper,
        silver_pieces: silver,
        electrum_pieces: electrum,
        gold_pieces: gold,
        platinum_pieces: platinum,
        total_gold_value: copper * 0.01 + silver * 0.1 + electrum * 0.5 + gold + platinum * 10,
        items: []
      }
    end

    def self.generate_individual_treasure_cr_11_16
      gold = DiceParser.roll('2d6')[:total] * 100
      platinum = DiceParser.roll('1d6')[:total] * 10

      {
        copper_pieces: 0,
        silver_pieces: 0,
        electrum_pieces: 0,
        gold_pieces: gold,
        platinum_pieces: platinum,
        total_gold_value: gold + platinum * 10,
        items: []
      }
    end

    def self.generate_individual_treasure_cr_17_plus
      gold = DiceParser.roll('2d6')[:total] * 1000
      platinum = DiceParser.roll('1d6')[:total] * 100

      {
        copper_pieces: 0,
        silver_pieces: 0,
        electrum_pieces: 0,
        gold_pieces: gold,
        platinum_pieces: platinum,
        total_gold_value: gold + platinum * 10,
        items: []
      }
    end
  end
end
