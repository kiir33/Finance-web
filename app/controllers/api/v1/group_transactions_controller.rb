module Api
  module V1
    class GroupTransactionsController < ApplicationController
      def index
        transactions = GroupTransaction.all
        render json: { data: transactions }, status: :ok
      end

      def show
        tx = GroupTransaction.find_by!(public_id: params[:id])
        render json: { data: tx }, status: :ok
      end

      def create
        tx = GroupTransaction.new(group_transaction_params)
        if tx.save
          render json: { data: tx }, status: :created
        else
          render json: { error: { code: "invalid_group_transaction", message: tx.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      private

      def group_transaction_params
        params.permit(:group_account_id, :amount, :transaction_type, :public_id, :lock_version)
      end
    end
  end
end
