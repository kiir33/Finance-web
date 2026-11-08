class LoansController < ApplicationController
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_loan, only: %i[show edit update destroy]

  def index
    @loans = Loan.where(deleted_at: nil).order(created_at: :desc)
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
    if @loan.update(loan_params)
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
    @loan = Loan.where(deleted_at: nil).find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:client_id)
  end
end
