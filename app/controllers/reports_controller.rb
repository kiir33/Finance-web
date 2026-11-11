class ReportsController < ApplicationController
  before_action :require_admin!

  def index
    @treasury = GroupAccount.where(deleted_at: nil).first
    @client_count = Client.where(deleted_at: nil).count
    @active_loan_count = Loan.where(deleted_at: nil).count
    # NOTE: loans currently has no monetary column (the principal/amount field
    # has not been migrated yet), so there is no total-loan-amount aggregate.
    @savings_account_count = SavingsAccount.where(deleted_at: nil).count
    # `balance` is derived from transactions (see SavingsAccount#balance), not a
    # column, so aggregate the ledger instead of summing a non-existent column.
    @total_savings_deposits = SavingsTransaction
      .where(deleted_at: nil, transaction_type: "deposit")
      .sum(:amount)
    @total_savings_withdrawals = SavingsTransaction
      .where(deleted_at: nil, transaction_type: "withdrawal")
      .sum(:amount)
    @total_savings_balance = @total_savings_deposits - @total_savings_withdrawals
    @recent_audit_logs = AuditLog.order(created_at: :desc).limit(10)
  end
end
