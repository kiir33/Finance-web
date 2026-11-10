require "test_helper"

class GroupTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get group_transactions_url
    assert_response :success
  end

  test "show renders for a signed-in admin" do
    get group_transaction_url(group_transactions(:one))
    assert_response :success
  end

  test "new renders a form" do
    get new_group_transaction_url
    assert_response :success
  end

  test "create adds a group transaction and redirects" do
    account = group_accounts(:one)
    assert_difference -> { GroupTransaction.count }, 1 do
      post group_transactions_url, params: { group_transaction: { group_account_id: account.id, amount: 100, transaction_type: "deposit" } }
    end
    assert_redirected_to group_transaction_path(GroupTransaction.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get group_transactions_url
    assert_redirected_to new_session_url
  end

  test "member is redirected away from group transactions" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get group_transactions_url
    assert_redirected_to root_path
  end
end
