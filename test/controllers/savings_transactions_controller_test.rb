require "test_helper"

class SavingsTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get savings_transactions_url
    assert_response :success
  end

  test "show renders for a signed-in admin" do
    get savings_transaction_url(savings_transactions(:one))
    assert_response :success
  end

  test "new renders a form" do
    get new_savings_transaction_url
    assert_response :success
  end

  test "create adds a savings transaction and redirects" do
    account = savings_accounts(:one)
    assert_difference -> { SavingsTransaction.count }, 1 do
      post savings_transactions_url, params: { savings_transaction: { savings_account_id: account.id, amount: 100, transaction_type: "deposit" } }
    end
    assert_redirected_to savings_transaction_path(SavingsTransaction.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get savings_transactions_url
    assert_redirected_to new_session_url
  end

  test "member only sees transactions on their own accounts" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get savings_transactions_url
    assert_response :success
    assert_includes response.body, savings_transactions(:one).id.to_s
    assert_not_includes response.body, savings_transactions(:two).id.to_s
  end
end
