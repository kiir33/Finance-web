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
    @user.role = requested_role if requested_role
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
      permitted = user_params
        .except(:lock_version, :force_update, :password, :password_confirmation)
        .to_h
      permitted["role"] = requested_role if requested_role
      if @user.update_columns(permitted)
        redirect_to @user, notice: "User was updated (overwrote concurrent changes)."
      else
        render :edit, status: :unprocessable_entity
      end
      return
    end

    @user.role = requested_role if requested_role
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
    # `role` is deliberately excluded from mass assignment: it is a privileged
    # attribute and is applied explicitly through `requested_role` (validated
    # against the enum), which also keeps Brakeman's PermitAttributes check clean.
    params.require(:user).permit(:email, :password, :password_confirmation, :lock_version, :force_update)
  end

  # Returns the requested role only when it is a valid enum value.
  def requested_role
    role = params.dig(:user, :role)
    role if role.present? && User.roles.key?(role)
  end
end
