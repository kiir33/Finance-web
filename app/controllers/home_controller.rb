class HomeController < ApplicationController
  def index
    if current_user.admin?
      @treasury = GroupAccount.first
      @client_count = Client.where(deleted_at: nil).count
      @active_loan_count = Loan.where(deleted_at: nil).count
      @pending_savings_txns = SavingsTransaction
        .includes(savings_account: :client)
        .order(created_at: :desc)
        .limit(5)
    else
      load_member_dashboard
    end
  end

  private

  def load_member_dashboard
    @my_client = current_user.clients.where(deleted_at: nil).first

    if @my_client
      @my_savings_accounts = @my_client.savings_accounts.where(deleted_at: nil).order(:id)
      @my_active_loans = @my_client.loans.where(deleted_at: nil).order(created_at: :desc)
      @my_repayments = LoanRepayment
        .joins(:loan)
        .where(deleted_at: nil, loans: { client_id: @my_client.id, deleted_at: nil })
        .order(created_at: :desc)
        .limit(5)
    else
      @my_savings_accounts = []
      @my_active_loans = []
      @my_repayments = []
    end
  end
end
