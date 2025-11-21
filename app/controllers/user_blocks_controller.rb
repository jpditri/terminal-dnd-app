# frozen_string_literal: true

class UserBlocksController < ApplicationController
  before_action :set_user
  before_action :set_user_block, only: [:destroy]

  def index
    @user_blockses = policy_scope(UserBlocks)
    @user_blockses = @user_blockses.search(params[:q]) if params[:q].present?
    @user_blockses = @user_blockses.page(params[:page]).per(20)
  end

  def create
    @user_blocks = UserBlocks.new(user_blocks_params)
    authorize @user_blocks

    respond_to do |format|
      if @user_blocks.save
        format.html { redirect_to @user_blocks, notice: 'UserBlocks was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user_blocks

    @user_blocks.destroy

    respond_to do |format|
      format.html { redirect_to user_blockses_path, notice: 'UserBlocks was successfully deleted.' }
      format.turbo_stream
    end
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_user_block
    # TODO: Implement set_user_block
  end

  private

  def set_user_blocks
    @user_blocks = UserBlocks.find(params[:id])
  end

  def user_blocks_params
    params.require(:user_blocks).permit()
  end

end