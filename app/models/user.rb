class User < ApplicationRecord
  has_secure_password

  enum :role, { member: 0, admin: 1 }, prefix: true

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: :password_required?

  before_create :generate_public_id

  has_many :members, dependent: :nullify
  has_many :audit_logs, dependent: :nullify

  scope :admins, -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }

  def admin?
    role_admin?
  end

  def member?
    role_member?
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
