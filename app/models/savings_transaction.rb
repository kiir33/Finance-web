class SavingsTransaction < ApplicationRecord
  belongs_to :savings_account

  validates :savings_account, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[deposit withdrawal] }

  before_create :generate_public_id

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
