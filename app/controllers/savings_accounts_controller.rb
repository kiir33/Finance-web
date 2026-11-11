class SavingsAccountsController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_account, only: %i[show edit update destroy]

  def index
    @accounts = visible_accounts.order(:id)
  end

  def show
  end

  def new
    @account = SavingsAccount.new
    @clients = Client.where(deleted_at: nil).order(:client_id)
  end

  def create
    @account = SavingsAccount.new(account_params)
    if @account.save
      redirect_to @account, notice: "Savings account was created."
    else
      @clients = Client.where(deleted_at: nil).order(:client_id)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clients = Client.where(deleted_at: nil).order(:client_id)
  end

  def update
    if @force_update_retry
      permitted = account_params.except(:lock_version, :force_update).to_h
      if @account.update_columns(permitted)
        redirect_to @account, notice: "Savings account was updated (overwrote concurrent changes)."
      else
        @clients = Client.where(deleted_at: nil).order(:client_id)
        render :edit, status: :unprocessable_entity
      end
    elsif @account.update(account_params)
      redirect_to @account, notice: "Savings account was updated."
    else
      @clients = Client.where(deleted_at: nil).order(:client_id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.update(deleted_at: Time.current)
    redirect_to savings_accounts_url, notice: "Savings account was archived."
  end

  private

  def set_account
    @account = visible_accounts.find(params[:id])
  end

  # Admins can see every account; members are limited to accounts belonging to their clients.
  def visible_accounts
    scope = SavingsAccount.where(deleted_at: nil)
    current_user.admin? ? scope : scope.where(client_id: current_user.clients.where(deleted_at: nil).ids)
  end

  def account_params
    params.require(:savings_account).permit(:client_id, :lock_version, :force_update)
  end
end
