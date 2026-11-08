class AuditLogsController < ApplicationController
  before_action :require_admin!

  def index
    @audit_logs = AuditLog.order(created_at: :desc)
  end
end
