class Client < ApplicationRecord
  belongs_to :user, optional: true

  validates :client_id, presence: true, uniqueness: true
  validates :name, presence: true

  before_create :generate_public_id

  has_many :savings_accounts, dependent: :destroy
  has_many :loans, dependent: :destroy

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
