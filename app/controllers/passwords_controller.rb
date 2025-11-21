# frozen_string_literal: true

class PasswordsController < ApplicationController
  before_action :require_authentication
  before_action :set_user_by_token, only: [:edit, :update]

  def new
    @passwords = Passwords.new
    authorize @passwords
  end

  def create
    @passwords = Passwords.new(passwords_params)
    authorize @passwords

    respond_to do |format|
      if @passwords.save
        format.html { redirect_to @passwords, notice: 'Passwords was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @passwords
  end

  def update
    authorize @passwords

    respond_to do |format|
      if @passwords.update(passwords_params)
        format.html { redirect_to @passwords, notice: 'Passwords was successfully updated.' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def require_authentication
    # TODO: Implement require_authentication
  end

  def set_user_by_token
    # TODO: Implement set_user_by_token
  end

  private

  def set_passwords
    @passwords = Passwords.find(params[:id])
  end

  def passwords_params
    params.require(:passwords).permit()
  end

end