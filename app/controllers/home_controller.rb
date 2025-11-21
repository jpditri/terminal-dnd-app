# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :require_authentication, only: [:index]

  def index
    @homes = policy_scope(Hom)
    @homes = @homes.search(params[:q]) if params[:q].present?
    @homes = @homes.page(params[:page]).per(20)
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  private

  def set_hom
    @hom = Hom.find(params[:id])
  end

  def hom_params
    params.require(:hom).permit()
  end

end