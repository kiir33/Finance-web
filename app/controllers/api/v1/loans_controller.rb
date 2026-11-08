module Api
  module V1
    class LoansController < ApplicationController
      def index
        loans = Loan.where(deleted_at: nil)
        render json: { data: loans }, status: :ok
      end

      def show
        loan = Loan.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: loan }, status: :ok
      end

      def create
        loan = Loan.new(loan_params)
        if loan.save
          render json: { data: loan }, status: :created
        else
          render json: { error: { code: "invalid_loan", message: loan.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def update
        loan = Loan.find_by!(public_id: params[:id], deleted_at: nil)
        if loan.update(loan_params)
          render json: { data: loan }, status: :ok
        else
          render json: { error: { code: "invalid_loan", message: loan.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def destroy
        loan = Loan.find_by!(public_id: params[:id])
        loan.update(deleted_at: Time.current)
        render json: { data: { message: "Loan deleted" } }, status: :ok
      end

      private

      def loan_params
        params.permit(:client_id, :public_id, :lock_version)
      end
    end
  end
end
