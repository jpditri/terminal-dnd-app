# frozen_string_literal: true

class SharedContentsController < ApplicationController
  before_action :set_user
  before_action :set_shared_content, only: [:show, :edit, :update, :destroy, :clone]

  def index
    @shared_contentses = policy_scope(SharedContents)
    @shared_contentses = @shared_contentses.search(params[:q]) if params[:q].present?
    @shared_contentses = @shared_contentses.page(params[:page]).per(20)
  end

  def show
    authorize @shared_contents
  end

  def new
    @shared_contents = SharedContents.new
    authorize @shared_contents
  end

  def create
    @shared_contents = SharedContents.new(shared_contents_params)
    authorize @shared_contents

    respond_to do |format|
      if @shared_contents.save
        format.html { redirect_to @shared_contents, notice: 'SharedContents was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @shared_contents
  end

  def update
    authorize @shared_contents

    respond_to do |format|
      if @shared_contents.update(shared_contents_params)
        format.html { redirect_to @shared_contents, notice: 'SharedContents was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @shared_contents

    @shared_contents.destroy

    respond_to do |format|
      format.html { redirect_to shared_contentses_path, notice: 'SharedContents was successfully deleted.' }
      format.turbo_stream
    end
  end

  def clone
    # TODO: Implement clone
  end

  def my_content
    # TODO: Implement my_content
  end

  def set_user
    # TODO: Implement set_user
  end

  def set_shared_content
    # TODO: Implement set_shared_content
  end

  private

  def set_shared_contents
    @shared_contents = SharedContents.find(params[:id])
  end

  def shared_contents_params
    params.require(:shared_contents).permit()
  end

end