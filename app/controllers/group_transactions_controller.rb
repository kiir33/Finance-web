class GroupTransactionsController < ApplicationController
  before_action :require_admin!

  def index
    @transactions = GroupTransaction.where(deleted_at: nil).order(created_at: :desc)
  end

  def show
    @transaction = GroupTransaction.where(deleted_at: nil).find(params[:id])
  end

  def new
    @transaction = GroupTransaction.new
    @accounts = GroupAccount.all
  end

  def create
    @transaction = GroupTransaction.new(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: "Group transaction was recorded."
    else
      @accounts = GroupAccount.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:group_transaction).permit(:group_account_id, :amount, :transaction_type)
  end
end
