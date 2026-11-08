class SavingsAccountsController < ApplicationController
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_account, only: %i[show edit update destroy]

  def index
    @accounts = SavingsAccount.where(deleted_at: nil).order(:id)
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
    if @account.update(account_params)
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
    @account = SavingsAccount.where(deleted_at: nil).find(params[:id])
  end

  def account_params
    params.require(:savings_account).permit(:client_id)
  end
end
