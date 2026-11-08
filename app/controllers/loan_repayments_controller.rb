class LoanRepaymentsController < ApplicationController
  before_action :require_admin!, only: %i[new create]
  before_action :set_loan, only: %i[new create]

  def index
    @repayments = LoanRepayment.order(created_at: :desc)
  end

  def show
    @repayment = LoanRepayment.find(params[:id])
  end

  def new
    @repayment = LoanRepayment.new
    @loans = Loan.where(deleted_at: nil).order(:id)
  end

  def create
    @repayment = LoanRepayment.new(repayment_params)
    if @repayment.save
      redirect_to @repayment, notice: "Loan repayment was recorded."
    else
      @loans = Loan.where(deleted_at: nil).order(:id)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def repayment_params
    params.require(:loan_repayment).permit(:loan_id, :amount)
  end
end
