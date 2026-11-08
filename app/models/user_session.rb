class UserSession < ApplicationRecord
  belongs_to :user

  # Clean up expired sessions periodically
  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_admin, -> { joins(:user).where(users: { role: :admin }) }

  MAX_ADMIN_SESSIONS = 3

  def self.prune_expired!
    where("expires_at <= ?", Time.current).delete_all
  end

  def self.admin_session_count
    active.for_admin.count
  end

  def self.can_create_admin_session?
    admin_session_count < MAX_ADMIN_SESSIONS
  end

  def self.create_for_user!(user, token, request, expires_in: 24.hours)
    # For admin users, enforce max concurrent sessions
    if user.admin?
      prune_expired!
      raise "Maximum concurrent admin sessions reached (#{MAX_ADMIN_SESSIONS})" unless can_create_admin_session?
    end

    token_digest = BCrypt::Password.create(token)
    create!(
      user: user,
      token_digest: token_digest,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      expires_at: expires_in.from_now
    )
  end

  def self.find_by_token(token)
    active.find do |session|
      BCrypt::Password.new(session.token_digest) == token
    end
  end

  def self.revoke_token(token)
    session = find_by_token(token)
    session&.destroy
  end

  def self.revoke_all_for_user(user)
    active.for_user(user).delete_all
  end
end
