class Loan < ApplicationRecord
  include Syncable

  belongs_to :member

  validates :member, presence: true

  before_create :generate_public_id

  has_many :loan_repayments, dependent: :destroy

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
