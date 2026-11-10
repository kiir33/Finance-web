class ReportsController < ApplicationController
  before_action :require_admin!

  def index
    @treasury = GroupAccount.where(deleted_at: nil).first
    @client_count = Client.where(deleted_at: nil).count
    @active_loan_count = Loan.where(deleted_at: nil).count
    @total_loan_amount = Loan.where(deleted_at: nil).sum(:amount)
    @savings_account_count = SavingsAccount.where(deleted_at: nil).count
    @total_savings_balance = SavingsAccount.where(deleted_at: nil).sum(:balance)
    @total_savings_deposits = SavingsTransaction
      .where(deleted_at: nil, transaction_type: "deposit")
      .sum(:amount)
    @total_savings_withdrawals = SavingsTransaction
      .where(deleted_at: nil, transaction_type: "withdrawal")
      .sum(:amount)
    @recent_audit_logs = AuditLog.order(created_at: :desc).limit(10)
  end
end
