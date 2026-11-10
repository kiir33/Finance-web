require "test_helper"

class LoanRepaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get loan_repayments_url
    assert_response :success
  end

  test "show renders for a signed-in admin" do
    get loan_repayment_url(loan_repayments(:one))
    assert_response :success
  end

  test "new renders a form" do
    get new_loan_repayment_url
    assert_response :success
  end

  test "create adds a loan repayment and redirects" do
    loan = loans(:one)
    assert_difference -> { LoanRepayment.count }, 1 do
      post loan_repayments_url, params: { loan_repayment: { loan_id: loan.id, amount: 50 } }
    end
    assert_redirected_to loan_repayment_path(LoanRepayment.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get loan_repayments_url
    assert_redirected_to new_session_url
  end

  test "member only sees repayments on their own loans" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get loan_repayments_url
    assert_response :success
    assert_includes response.body, loan_repayments(:one).id.to_s
    assert_not_includes response.body, loan_repayments(:two).id.to_s
  end

  test "member cannot view a repayment on another client's loan" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get loan_repayment_url(loan_repayments(:two))
    assert_response :not_found
  end
end
