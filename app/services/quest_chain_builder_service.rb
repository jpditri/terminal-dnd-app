# frozen_string_literal: true

class QuestChainBuilderService
  attr_reader :campaign, :chain_id

  def initialize(campaign: Campaign.new, chain_id: ChainId.new)
    @campaign = campaign
    @chain_id = chain_id
  end


  def build_chain(quests_data)
    # TODO: Implement
  end

  def add_quest_to_chain(quest_data, position: nil)
    # TODO: Implement
  end

  def visualization_data(chain_id = @chain_id)
    # TODO: Implement
  end

  def calculate_chain_rewards(party_level:, chain_length:, difficulty:)
    # TODO: Implement
  end
end