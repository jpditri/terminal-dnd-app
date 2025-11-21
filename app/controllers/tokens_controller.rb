# frozen_string_literal: true

class TokensController < ApplicationController
  before_action :require_authentication
  before_action :set_map
  before_action :set_token

  def index
    @tokenses = policy_scope(Tokens)
    @tokenses = @tokenses.search(params[:q]) if params[:q].present?
    @tokenses = @tokenses.page(params[:page]).per(20)
  end

  def show
    authorize @tokens
  end

  def new
    @tokens = Tokens.new
    authorize @tokens
  end

  def edit
    authorize @tokens
  end

  def create
    @tokens = Tokens.new(tokens_params)
    authorize @tokens

    respond_to do |format|
      if @tokens.save
        format.html { redirect_to @tokens, notice: 'Tokens was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @tokens

    respond_to do |format|
      if @tokens.update(tokens_params)
        format.html { redirect_to @tokens, notice: 'Tokens was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @tokens

    @tokens.destroy

    respond_to do |format|
      format.html { redirect_to tokenses_path, notice: 'Tokens was successfully deleted.' }
      format.turbo_stream
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_map
    # TODO: Implement set_map
  end

  def set_token
    # TODO: Implement set_token
  end

  private

  def set_tokens
    @tokens = Tokens.find(params[:id])
  end

  def tokens_params
    params.require(:tokens).permit()
  end

end