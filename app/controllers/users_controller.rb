# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user

  def index
    @userses = policy_scope(Users)
    @userses = @userses.search(params[:q]) if params[:q].present?
    @userses = @userses.page(params[:page]).per(20)
  end

  def show
    authorize @users
  end

  def edit
    authorize @users
  end

  def new
    @users = Users.new
    authorize @users
  end

  def create
    @users = Users.new(users_params)
    authorize @users

    respond_to do |format|
      if @users.save
        format.html { redirect_to @users, notice: 'Users was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @users

    respond_to do |format|
      if @users.update(users_params)
        format.html { redirect_to @users, notice: 'Users was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @users

    @users.destroy

    respond_to do |format|
      format.html { redirect_to userses_path, notice: 'Users was successfully deleted.' }
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

  def set_user
    # TODO: Implement set_user
  end

  private

  def set_users
    @users = Users.find(params[:id])
  end

  def users_params
    params.require(:users).permit()
  end

end