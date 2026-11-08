class SavingsAccount < ApplicationRecord
  include Syncable

  belongs_to :client

  validates :client, presence: true

  before_create :generate_public_id

  has_many :savings_transactions, dependent: :destroy

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
