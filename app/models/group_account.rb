class GroupAccount < ApplicationRecord
  validates :cash_balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bank_balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_create :generate_public_id

  has_many :group_transactions, dependent: :destroy

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
