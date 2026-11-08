class SyncOutbox < ApplicationRecord
  validates :record_type, presence: true
  validates :changed_at, presence: true
end
