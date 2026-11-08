# Syncable concern: records every create/update/soft-delete into sync_outbox
# so the delta sync endpoint (GET /api/v1/sync?since=) can stream changes
# to mobile clients. Soft-deleted records are emitted as tombstones
# (deleted: true).
module Syncable
  extend ActiveSupport::Concern

  included do
    after_commit :log_sync_change, on: %i[create update]
    after_commit :log_sync_delete, on: :destroy
  end

  private

  def log_sync_change
    SyncOutbox.create!(
      record_type: self.class.name.demodulize.underscore,
      record_id: id.to_s,
      public_id: public_id.to_s,
      changed_at: updated_at,
      deleted: deleted_at.present?
    )
  end

  def log_sync_delete
    SyncOutbox.create!(
      record_type: self.class.name.demodulize.underscore,
      record_id: id.to_s,
      public_id: public_id.to_s,
      changed_at: updated_at,
      deleted: true
    )
  end
end
