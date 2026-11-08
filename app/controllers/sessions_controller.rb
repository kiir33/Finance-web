class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout nil

  def new
    render :new
  end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      start_session(user)
      if request.format.json?
        render json: { data: { token: issue_jwt(user), user: { id: user.id, email: user.email, role: user.role } } }, status: :ok
      else
        redirect_to root_path, notice: "Signed in successfully"
      end
    else
      if request.format.json?
        render json: { error: { code: "invalid_credentials", message: "Invalid email or password" } }, status: :unauthorized
      else
        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    end_session
    if request.format.json?
      render json: { data: { message: "Logged out" } }, status: :ok
    else
      redirect_to new_session_path, notice: "Signed out"
    end
  end
end
