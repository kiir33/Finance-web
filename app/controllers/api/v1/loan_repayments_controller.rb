module Api
  module V1
    class LoanRepaymentsController < ApplicationController
      def index
        repayments = LoanRepayment.where(deleted_at: nil)
        render json: { data: repayments }, status: :ok
      end

      def show
        repayment = LoanRepayment.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: repayment }, status: :ok
      end

      def create
        repayment = LoanRepayment.new(loan_repayment_params)
        if repayment.save
          render json: { data: repayment }, status: :created
        else
          render json: { error: { code: "invalid_loan_repayment", message: repayment.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      private

      def loan_repayment_params
        params.permit(:loan_id, :amount, :public_id, :lock_version)
      end
    end
  end
end
