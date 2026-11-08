class GroupAccountsController < ApplicationController
  before_action :require_admin!
  before_action :set_account

  def index
    redirect_to group_account_path(@account)
  end

  def show
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: "Treasury balances were updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = GroupAccount.where(deleted_at: nil).first || GroupAccount.create!(cash_balance: 0, bank_balance: 0)
  end

  def account_params
    params.require(:group_account).permit(:cash_balance, :bank_balance)
  end
end
