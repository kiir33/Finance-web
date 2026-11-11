class GroupAccountsController < ApplicationController
  include ConcurrencyHandling
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
    if @force_update_retry
      permitted = account_params.except(:lock_version, :force_update).to_h
      if @account.update_columns(permitted)
        redirect_to @account, notice: "Treasury balances were updated (overwrote concurrent changes)."
      else
        render :edit, status: :unprocessable_entity
      end
    elsif @account.update(account_params)
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
    params.require(:group_account).permit(:cash_balance, :bank_balance, :lock_version, :force_update)
  end
end
