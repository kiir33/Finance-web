class UsersController < ApplicationController
  include ConcurrencyHandling

  before_action :require_admin!
  before_action :set_user, only: %i[show edit update]

  def index
    @users = User.order(:email)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Bypass optimistic locking for concurrent edit "Save Anyway".
    # Check force_update BEFORE calling @user.update so the StaleObjectError
    # is never raised and the overwrite actually persists.
    if params[:force_update] == "true" || params.dig(:user, :force_update) == "true"
      permitted = user_params.except(:lock_version, :force_update, :password, :password_confirmation)
      if @user.update_columns(permitted)
        redirect_to @user, notice: "User was updated (overwrote concurrent changes)."
      else
        render :edit, status: :unprocessable_entity
      end
      return
    end

    if @user.update(user_params)
      redirect_to @user, notice: "User was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :lock_version, :force_update)
  end
end
