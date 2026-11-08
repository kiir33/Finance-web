module Api
  module V1
    class ApplicationController < ActionController::API
      include Authentication

      # API controllers authenticate via JWT/session and return JSON 401.
      before_action :authenticate_api!

      private

      def admin_only!
        return true if current_user&.admin?

        render json: { error: { code: "forbidden", message: "Admin access required" } }, status: :forbidden
        false
      end
    end
  end
end
