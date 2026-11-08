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
      skip_before_action :authenticate_api!, **options
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

  # API-specific authentication: returns JSON 401 instead of redirecting.
  # Applied to API controllers via `before_action :authenticate_api!`.
  def authenticate_api!
    return if current_user

    render json: { error: { code: "unauthenticated", message: "Login required" } }, status: :unauthorized
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers["Authorization"]
    header&.gsub(pattern, "")
  end

  def authenticate_jwt(token)
    return unless token

    payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first

    # Check if token is revoked
    return nil if TokenBlocklist.revoked?(payload["jti"])

    user = User.find_by(id: payload["user_id"])

    # For JWT tokens, verify user session exists and is valid
    if user && payload["jti"]
      user_session = UserSession.active.find_by(user: user)
      return nil unless user_session && BCrypt::Password.new(user_session.token_digest) == token
    end

    user
  rescue JWT::DecodeError, JWT::ExpiredSignature, BCrypt::Errors::InvalidHash
    nil
  end

  def issue_jwt(user)
    jti = SecureRandom.uuid
    exp = 24.hours.from_now.to_i
    payload = { user_id: user.id, exp: exp, jti: jti }
    token = JWT.encode(payload, ENV.fetch("API_TOKEN_SECRET"), "HS256")

    # Create user session for tracking
    UserSession.create_for_user!(user, token, request, expires_in: 24.hours)

    token
  end

  def revoke_jwt(token)
    return unless token

    payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first
    TokenBlocklist.revoke!(payload["jti"], Time.at(payload["exp"]), current_user) if payload["jti"] && payload["exp"]
    UserSession.revoke_token(token)
  rescue JWT::DecodeError
    nil
  end

  def start_session(user)
    session[:user_id] = user.id
  end

  def end_session
    session.delete(:user_id)
  end
end