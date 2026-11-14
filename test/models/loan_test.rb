require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "requires a member" do
    loan = Loan.new
    assert_not loan.valid?
    assert_includes loan.errors[:member], "must exist"
  end

  test "generates a public_id before create" do
    loan = Loan.create!(member: members(:one))
    assert loan.public_id.present?
  end
end
