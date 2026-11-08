require "test_helper"

class GroupAccountTest < ActiveSupport::TestCase
  test "balances must not be negative" do
    account = GroupAccount.new(cash_balance: -10, bank_balance: -5)
    assert_not account.valid?
    assert_includes account.errors[:cash_balance], "must be greater than or equal to 0"
    assert_includes account.errors[:bank_balance], "must be greater than or equal to 0"
  end

  test "zero balances are valid" do
    account = GroupAccount.new(cash_balance: 0, bank_balance: 0)
    assert account.valid?
  end
end
