# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @searches = policy_scope(Search)
    @searches = @searches.search(params[:q]) if params[:q].present?
    @searches = @searches.page(params[:page]).per(20)
  end

  def results
    # TODO: Implement results
  end

  def recent
    # TODO: Implement recent
  end

  private

  def set_search
    @search = Search.find(params[:id])
  end

  def search_params
    params.require(:search).permit()
  end

end