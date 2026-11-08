class LoanRepayment < ApplicationRecord
  belongs_to :loan

  validates :loan, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  before_create :generate_public_id

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
