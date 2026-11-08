class SavingsTransactionsController < ApplicationController
  before_action :require_admin!, only: %i[new create]
  before_action :set_accounts, only: %i[new create]

  def index
    @transactions = SavingsTransaction.order(created_at: :desc)
  end

  def show
    @transaction = SavingsTransaction.find(params[:id])
  end

  def new
    @transaction = SavingsTransaction.new
  end

  def create
    @transaction = SavingsTransaction.new(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: "Savings transaction was recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_accounts
    @accounts = SavingsAccount.where(deleted_at: nil).order(:id)
  end

  def transaction_params
    params.require(:savings_transaction).permit(:savings_account_id, :amount, :transaction_type)
  end
end
