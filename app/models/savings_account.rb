class SavingsAccount < ApplicationRecord
  include Syncable

  belongs_to :member

  validates :member, presence: true

  before_create :generate_public_id

  has_many :savings_transactions, dependent: :destroy

  # Current balance derived from non-deleted transactions (deposits minus withdrawals).
  def balance
    deposits = savings_transactions.where(deleted_at: nil, transaction_type: "deposit").sum(:amount)
    withdrawals = savings_transactions.where(deleted_at: nil, transaction_type: "withdrawal").sum(:amount)
    deposits - withdrawals
  end

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
