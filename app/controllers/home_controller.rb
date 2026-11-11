class HomeController < ApplicationController
  def index
    if current_user.admin?
      @treasury = GroupAccount.where(deleted_at: nil).first
      @member_count = Member.where(deleted_at: nil).count
      @active_loan_count = Loan.where(deleted_at: nil).count
      @pending_savings_txns = SavingsTransaction
        .where(deleted_at: nil)
        .includes(savings_account: :member)
        .order(created_at: :desc)
        .limit(5)
    else
      load_member_dashboard
    end
  end

  private

  def load_member_dashboard
    @my_member = current_user.members.where(deleted_at: nil).first

    if @my_member
      @my_savings_accounts = @my_member.savings_accounts.where(deleted_at: nil).order(:id)
      @my_active_loans = @my_member.loans.where(deleted_at: nil).order(created_at: :desc)
      @my_repayments = LoanRepayment
        .joins(:loan)
        .where(deleted_at: nil, loans: { member_id: @my_member.id, deleted_at: nil })
        .order(created_at: :desc)
        .limit(5)
    else
      @my_savings_accounts = []
      @my_active_loans = []
      @my_repayments = []
    end
  end
end
