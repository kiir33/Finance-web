require "test_helper"

class SavingsTransactionTest < ActiveSupport::TestCase
  test "requires savings_account, amount and transaction_type" do
    txn = SavingsTransaction.new
    assert_not txn.valid?
    assert_includes txn.errors[:savings_account], "must exist"
    assert_includes txn.errors[:amount], "can't be blank"
    assert_includes txn.errors[:transaction_type], "can't be blank"
  end

  test "transaction_type must be deposit or withdrawal" do
    txn = SavingsTransaction.new(savings_account: savings_accounts(:one), amount: 100, transaction_type: "invalid")
    assert_not txn.valid?
    assert_includes txn.errors[:transaction_type], "is not included in the list"
  end

  test "amount must be present and numeric" do
    txn = SavingsTransaction.new(savings_account: savings_accounts(:one), transaction_type: "deposit")
    assert_not txn.valid?
    assert_includes txn.errors[:amount], "can't be blank"
  end
end
