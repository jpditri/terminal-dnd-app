# frozen_string_literal: true

class NpcsController < ApplicationController
  before_action :set_npc, only: [:show, :edit, :update, :destroy, :restore, :history, :interactions, :update_relationship]
  before_action :set_campaign, only: [:index, :new, :create, :quick_create, :generate_random]

  def index
    @npcs = policy_scope(Npc).for_campaign(@campaign)
    @npcs = @npcs.where('name ILIKE ?', "%#{params[:q]}%") if params[:q].present?
    @npcs = @npcs.page(params[:page]).per(20)
  end

  def show
    authorize @npc
  end

  def edit
    authorize @npc
  end

  def new
    @npc = Npc.new(campaign: @campaign)
    authorize @npc
  end

  def create
    @npc = Npc.new(npc_params.merge(campaign: @campaign))
    authorize @npc

    respond_to do |format|
      if @npc.save
        format.html { redirect_to @npc, notice: 'NPC was successfully created.' }
        format.turbo_stream
        format.json { render json: @npc, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @npc.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @npc

    respond_to do |format|
      if @npc.update(npc_params)
        format.html { redirect_to @npc, notice: 'NPC was successfully updated.' }
        format.turbo_stream
        format.json { render json: @npc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @npc.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @npc

    @npc.discard

    respond_to do |format|
      format.html { redirect_to npcs_path, notice: 'NPC was successfully deleted.' }
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  def restore
    authorize @npc
    @npc.undiscard

    respond_to do |format|
      format.html { redirect_to @npc, notice: 'NPC was successfully restored.' }
      format.turbo_stream
      format.json { render json: @npc }
    end
  end

  def history
    authorize @npc
    @versions = @npc.versions.order(created_at: :desc).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.json { render json: @versions }
    end
  end

  def interactions
    authorize @npc
    @interactions = @npc.npc_interactions.order(created_at: :desc).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.json { render json: @interactions }
    end
  end

  def add_interaction
    authorize @npc

    interaction = @npc.npc_interactions.create!(
      character_id: params[:character_id],
      interaction_type: params[:interaction_type] || 'conversation',
      content: params[:content],
      location: params[:location],
      context: params[:context]
    )

    respond_to do |format|
      format.html { redirect_to interactions_npc_path(@npc), notice: 'Interaction recorded.' }
      format.turbo_stream
      format.json { render json: interaction, status: :created }
    end
  end

  def update_relationship
    authorize @npc

    relationships = @npc.relationships || {}
    target = params[:target_name] || params[:target_id]
    relationships[target] = params[:relationship_value]

    @npc.update!(relationships: relationships)

    respond_to do |format|
      format.html { redirect_to @npc, notice: 'Relationship updated.' }
      format.turbo_stream
      format.json { render json: @npc }
    end
  end

  def quick_create
    authorize Npc.new(campaign: @campaign)

    spawner = SoloPlay::NpcSpawner.new(@campaign)
    archetype = params[:archetype] || 'guard'

    npc = Npc.new(
      campaign: @campaign,
      name: params[:name] || spawner.send(:generate_name),
      occupation: spawner.send(:load_npc_template, archetype)&.dig(:occupation) || 'Commoner',
      age: rand(18..70)
    )

    personality = spawner.generate_personality(occupation: npc.occupation)
    npc.assign_attributes(personality)

    spawner.assign_stats(
      npc,
      type: archetype,
      character_level: params[:level]&.to_i || 1,
      combat_ready: params[:combat_ready] == 'true'
    )

    if npc.save
      respond_to do |format|
        format.html { redirect_to npc, notice: "#{npc.name} was quickly created!" }
        format.turbo_stream
        format.json { render json: npc, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to npcs_path, alert: 'Failed to create NPC' }
        format.json { render json: npc.errors, status: :unprocessable_entity }
      end
    end
  end

  def generate_random
    authorize Npc.new(campaign: @campaign)

    spawner = SoloPlay::NpcSpawner.new(@campaign)
    archetypes = SoloPlay::NpcSpawner::NPC_ARCHETYPES.keys
    archetype = archetypes.sample

    npc = Npc.new(
      campaign: @campaign,
      name: spawner.send(:generate_name),
      age: rand(18..70)
    )

    template = spawner.send(:load_npc_template, archetype)
    npc.occupation = template[:occupation]

    personality = spawner.generate_personality(occupation: npc.occupation)
    npc.assign_attributes(personality)

    spawner.assign_stats(
      npc,
      type: archetype,
      character_level: rand(1..5),
      combat_ready: template[:combat_ready]
    )

    if npc.save
      respond_to do |format|
        format.html { redirect_to npc, notice: "Random NPC generated: #{npc.name} the #{npc.occupation}!" }
        format.turbo_stream
        format.json { render json: npc, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to npcs_path, alert: 'Failed to generate random NPC' }
        format.json { render json: npc.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_npc
    @npc = Npc.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to npcs_path, alert: 'NPC not found' }
      format.json { render json: { error: 'NPC not found' }, status: :not_found }
    end
  end

  def set_campaign
    @campaign = current_user.campaigns.first || Campaign.first
    unless @campaign
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'No campaign found' }
        format.json { render json: { error: 'No campaign found' }, status: :not_found }
      end
    end
  end

  def npc_params
    params.require(:npc).permit(
      :name, :occupation, :age, :race_id, :character_class_id, :alignment_id,
      :personality_traits, :ideals, :bonds, :flaws, :voice_style, :speech_patterns,
      :motivations, :secrets, :backstory, :importance_level, :status,
      :faction_id, :location_id, :world_id,
      :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma,
      :armor_class, :hit_points, :max_hit_points, :hit_dice, :level, :proficiency_bonus,
      :speed, :challenge_rating, :initiative,
      :damage_resistances, :damage_immunities, :condition_immunities, :conditions,
      :ai_personality_profile, :conversation_memory, :relationships,
      saving_throws: {}, skills: {}
    )
  end
end
