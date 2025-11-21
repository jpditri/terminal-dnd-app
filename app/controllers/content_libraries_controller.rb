# frozen_string_literal: true

class ContentLibrariesController < ApplicationController
  before_action :require_authentication
  before_action :set_content_library

  def index
    @content_librarieses = policy_scope(ContentLibraries)
    @content_librarieses = @content_librarieses.search(params[:q]) if params[:q].present?
    @content_librarieses = @content_librarieses.page(params[:page]).per(20)
  end

  def show
    authorize @content_libraries
  end

  def new
    @content_libraries = ContentLibraries.new
    authorize @content_libraries
  end

  def create
    @content_libraries = ContentLibraries.new(content_libraries_params)
    authorize @content_libraries

    respond_to do |format|
      if @content_libraries.save
        format.html { redirect_to @content_libraries, notice: 'ContentLibraries was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @content_libraries

    respond_to do |format|
      if @content_libraries.update(content_libraries_params)
        format.html { redirect_to @content_libraries, notice: 'ContentLibraries was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @content_libraries

    @content_libraries.destroy

    respond_to do |format|
      format.html { redirect_to content_librarieses_path, notice: 'ContentLibraries was successfully deleted.' }
      format.turbo_stream
    end
  end

  def upvote
    # TODO: Implement upvote
  end

  def downvote
    # TODO: Implement downvote
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_content_library
    # TODO: Implement set_content_library
  end

  private

  def set_content_libraries
    @content_libraries = ContentLibraries.find(params[:id])
  end

  def content_libraries_params
    params.require(:content_libraries).permit()
  end

end