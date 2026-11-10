class LoanRepaymentsController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create]

  def index
    @repayments = visible_repayments.order(created_at: :desc)
  end

  def show
    @repayment = visible_repayments.find(params[:id])
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

  # Admins can see every repayment; members only repayments on their own loans.
  # Optionally narrow to a single loan with ?loan_id=.
  def visible_repayments
    scope = LoanRepayment.where(deleted_at: nil)
    scope = scope.where(loan_id: params[:loan_id]) if params[:loan_id].present?
    return scope if current_user.admin?

    scope.joins(:loan).where(loans: { client_id: current_user.clients.where(deleted_at: nil).ids })
  end

  def repayment_params
    params.require(:loan_repayment).permit(:loan_id, :amount, :lock_version, :force_update)
  end
end