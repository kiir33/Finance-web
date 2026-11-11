class LoansController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_loan, only: %i[show edit update destroy]

  def index
    @loans = visible_loans.order(created_at: :desc)
  end

  def show
  end

  def new
    @loan = Loan.new
    @clients = Client.where(deleted_at: nil).order(:client_id)
  end

  def create
    @loan = Loan.new(loan_params)
    if @loan.save
      redirect_to @loan, notice: "Loan was created."
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
      permitted = loan_params.except(:lock_version, :force_update).to_h
      if @loan.update_columns(permitted)
        redirect_to @loan, notice: "Loan was updated (overwrote concurrent changes)."
      else
        @clients = Client.where(deleted_at: nil).order(:client_id)
        render :edit, status: :unprocessable_entity
      end
    elsif @loan.update(loan_params)
      redirect_to @loan, notice: "Loan was updated."
    else
      @clients = Client.where(deleted_at: nil).order(:client_id)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @loan.update(deleted_at: Time.current)
    redirect_to loans_url, notice: "Loan was archived."
  end

  private

  def set_loan
    @loan = visible_loans.find(params[:id])
  end

  # Admins can see every loan; members are limited to loans belonging to their clients.
  def visible_loans
    scope = Loan.where(deleted_at: nil)
    current_user.admin? ? scope : scope.where(client_id: current_user.clients.where(deleted_at: nil).ids)
  end

  def loan_params
    params.require(:loan).permit(:client_id, :lock_version, :force_update)
  end
end
