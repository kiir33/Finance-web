class HomeController < ApplicationController
  def index
    if current_user.admin?
      @treasury = GroupAccount.first
      @client_count = Client.where(deleted_at: nil).count
      @active_loan_count = Loan.where(deleted_at: nil).count
      @pending_savings_txns = SavingsTransaction.order(created_at: :desc).limit(5)
    else
      @my_repayments = []
    end
  end
end
