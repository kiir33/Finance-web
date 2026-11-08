require "test_helper"

class SavingsAccountTest < ActiveSupport::TestCase
  test "balance sums deposits and subtracts withdrawals" do
    account = savings_accounts(:one)

    assert_equal BigDecimal("100"), account.balance
  end
end
