class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true

  before_create :generate_public_id

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
