module Api
  module V1
    class GroupAccountsController < ApplicationController
      def index
        accounts = GroupAccount.all
        render json: { data: accounts }, status: :ok
      end

      def show
        account = GroupAccount.find_by!(public_id: params[:id])
        render json: { data: account }, status: :ok
      end
    end
  end
end
