module Api
  module V1
    class AuthController < ApplicationController
      allow_unauthenticated_access only: %i[login]

      def login
        user = User.authenticate_by(email: params[:email], password: params[:password])

        if user
          start_session(user)
          token = issue_jwt(user)
          render json: {
            data: {
              token: token,
              user: { id: user.id, email: user.email, role: user.role }
            }
          }, status: :ok
        else
          render json: {
            error: { code: "invalid_credentials", message: "Invalid email or password" }
          }, status: :unauthorized
        end
      rescue RuntimeError => e
        render json: {
          error: { code: "max_admin_sessions", message: e.message }
        }, status: :forbidden
      end

      def logout
        token = bearer_token
        revoke_jwt(token) if token
        end_session
        render json: { data: { message: "Logged out" } }, status: :ok
      end

      def password_change
        if current_user.update(params.permit(:password, :password_confirmation))
          render json: { data: { message: "Password changed" } }, status: :ok
        else
          render json: {
            error: { code: "invalid_password", message: current_user.errors.full_messages.join(", ") }
          }, status: :unprocessable_entity
        end
      end
    end
  end
end