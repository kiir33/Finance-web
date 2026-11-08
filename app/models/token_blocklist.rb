class TokenBlocklist < ApplicationRecord
  # Clean up expired tokens periodically
  scope :active, -> { where("exp > ?", Time.current) }

  def self.revoked?(jti)
    active.exists?(jti: jti)
  end

  def self.revoke!(jti, exp, user)
    create!(jti: jti, exp: exp, user_id: user.id)
  end

  def self.cleanup_expired!
    where("exp <= ?", Time.current).delete_all
  end
end
