module Api
  module V1
    class SavingsTransactionsController < ApplicationController
      def index
        transactions = SavingsTransaction.where(deleted_at: nil)
        render json: { data: transactions }, status: :ok
      end

      def show
        tx = SavingsTransaction.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: tx }, status: :ok
      end

      def create
        tx = SavingsTransaction.new(savings_transaction_params)
        if tx.save
          render json: { data: tx }, status: :created
        else
          render json: { error: { code: "invalid_savings_transaction", message: tx.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      private

      def savings_transaction_params
        params.permit(:savings_account_id, :amount, :transaction_type, :public_id, :lock_version)
      end
    end
  end
end
