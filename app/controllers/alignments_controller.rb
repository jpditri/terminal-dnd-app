# frozen_string_literal: true

class AlignmentsController < ApplicationController
  before_action :set_alignment

  def index
    @alignmentses = policy_scope(Alignments)
    @alignmentses = @alignmentses.search(params[:q]) if params[:q].present?
    @alignmentses = @alignmentses.page(params[:page]).per(20)
  end

  def show
    authorize @alignments
  end

  def edit
    authorize @alignments
  end

  def new
    @alignments = Alignments.new
    authorize @alignments
  end

  def create
    @alignments = Alignments.new(alignments_params)
    authorize @alignments

    respond_to do |format|
      if @alignments.save
        format.html { redirect_to @alignments, notice: 'Alignments was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @alignments

    respond_to do |format|
      if @alignments.update(alignments_params)
        format.html { redirect_to @alignments, notice: 'Alignments was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @alignments

    @alignments.destroy

    respond_to do |format|
      format.html { redirect_to alignmentses_path, notice: 'Alignments was successfully deleted.' }
      format.turbo_stream
    end
  end

  def inline_update
    # TODO: Implement inline_update
  end

  def restore
    # TODO: Implement restore
  end

  def history
    # TODO: Implement history
  end

  def bulk_destroy
    # TODO: Implement bulk_destroy
  end

  def bulk_restore
    # TODO: Implement bulk_restore
  end

  def export
    # TODO: Implement export
  end

  def set_alignment
    # TODO: Implement set_alignment
  end

  private

  def set_alignments
    @alignments = Alignments.find(params[:id])
  end

  def alignments_params
    params.require(:alignments).permit()
  end

end