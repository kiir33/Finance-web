# Concern for authenticating users via session (web) or JWT (mobile API).
module Authentication
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :current_user, :user_signed_in?
    end
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def require_authentication
    @current_user ||= resume_session
    request_authentication unless @current_user
  end

  def resume_session
    if session[:user_id]
      User.find_by(id: session[:user_id])
    elsif (token = bearer_token)
      authenticate_jwt(token)
    end
  end

  def current_user
    @current_user ||= resume_session
  end

  def user_signed_in?
    current_user.present?
  end

  def request_authentication
    if request.format.json?
      render json: { error: { code: "unauthenticated", message: "Login required" } }, status: :unauthorized
    else
      redirect_to new_session_path
    end
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers["Authorization"]
    header&.gsub(pattern, "")
  end

  def authenticate_jwt(token)
    return unless token

    payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first
    User.find_by(id: payload["user_id"])
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def issue_jwt(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, ENV.fetch("API_TOKEN_SECRET"), "HS256")
  end

  def start_session(user)
    session[:user_id] = user.id
  end

  def end_session
    session.delete(:user_id)
  end
end
