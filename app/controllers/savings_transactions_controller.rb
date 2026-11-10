class SavingsTransactionsController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create]
  before_action :set_accounts, only: %i[new create]

  def index
    @transactions = visible_transactions.order(created_at: :desc)
  end

  def show
    @transaction = visible_transactions.find(params[:id])
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

  # Admins can see every transaction; members only transactions on their own accounts.
  def visible_transactions
    scope = SavingsTransaction.where(deleted_at: nil)
    return scope if current_user.admin?

    account_ids = SavingsAccount
      .where(client_id: current_user.clients.where(deleted_at: nil).ids)
      .ids
    scope.where(savings_account_id: account_ids)
  end

  def transaction_params
    params.require(:savings_transaction).permit(:savings_account_id, :amount, :transaction_type, :lock_version, :force_update)
  end
end