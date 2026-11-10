class SystemConfig < ApplicationRecord
  include Syncable

  validates :config_key, presence: true, uniqueness: true
  validates :config_value, presence: true
  validates :config_type, presence: true, inclusion: { in: %w[savings loan] }

  before_create :generate_public_id

  scope :savings_configs, -> { where(config_type: "savings") }
  scope :loan_configs, -> { where(config_type: "loan") }

  def to_param
    config_key
  end

  private

  def generate_public_id
    self.public_id ||= SecureRandom.uuid
  end
end