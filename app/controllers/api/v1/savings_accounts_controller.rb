module Api
  module V1
    class SavingsAccountsController < ApplicationController
      def index
        accounts = SavingsAccount.where(deleted_at: nil)
        render json: { data: accounts }, status: :ok
      end

      def show
        account = SavingsAccount.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: account }, status: :ok
      end

      def create
        account = SavingsAccount.new(savings_account_params)
        if account.save
          render json: { data: account }, status: :created
        else
          render json: { error: { code: "invalid_savings_account", message: account.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def update
        account = SavingsAccount.find_by!(public_id: params[:id], deleted_at: nil)
        if account.update(savings_account_params)
          render json: { data: account }, status: :ok
        else
          render json: { error: { code: "invalid_savings_account", message: account.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def destroy
        account = SavingsAccount.find_by!(public_id: params[:id])
        account.update(deleted_at: Time.current)
        render json: { data: { message: "Savings account deleted" } }, status: :ok
      end

      private

      def savings_account_params
        params.permit(:client_id, :public_id, :lock_version)
      end
    end
  end
end
