class GroupTransaction < ApplicationRecord
  belongs_to :group_account

  validates :group_account, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true

  before_create :generate_public_id

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
