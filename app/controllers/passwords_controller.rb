class PasswordsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :require_authentication, only: %i[edit update]
  layout nil

  def edit
    render :edit
  end

  def update
    if current_user.update(params.permit(:password, :password_confirmation))
      if request.format.json?
        render json: { data: { message: "Password changed" } }, status: :ok
      else
        redirect_to root_path, notice: "Password changed"
      end
    else
      if request.format.json?
        render json: { error: { code: "invalid_password", message: current_user.errors.full_messages.join(", ") } }, status: :unprocessable_entity
      else
        flash.now[:alert] = current_user.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
