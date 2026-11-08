require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "requires a client" do
    loan = Loan.new
    assert_not loan.valid?
    assert_includes loan.errors[:client], "must exist"
  end

  test "generates a public_id before create" do
    loan = Loan.create!(client: clients(:one))
    assert loan.public_id.present?
  end
end
