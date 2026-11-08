module Api
  module V1
    class AuditLogsController < ApplicationController
      def index
        logs = AuditLog.order(created_at: :desc)
        render json: { data: logs }, status: :ok
      end
    end
  end
end
