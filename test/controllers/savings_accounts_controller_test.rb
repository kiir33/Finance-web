require "test_helper"

class SavingsAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get savings_accounts_url
    assert_response :success
  end

  test "new renders a form" do
    get new_savings_account_url
    assert_response :success
  end

  test "create adds a savings account and redirects" do
    client = clients(:one)
    assert_difference -> { SavingsAccount.count }, 1 do
      post savings_accounts_url, params: { savings_account: { client_id: client.id } }
    end
    assert_redirected_to savings_account_path(SavingsAccount.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get savings_accounts_url
    assert_redirected_to new_session_url
  end

  test "member only sees accounts linked to their own clients" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get savings_accounts_url
    assert_response :success
    assert_includes response.body, savings_accounts(:one).id.to_s
    assert_not_includes response.body, savings_accounts(:two).id.to_s
  end

  test "member cannot view an account linked to another client" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get savings_account_url(savings_accounts(:two))
    assert_response :not_found
  end

  test "edit renders form for admin" do
    get edit_savings_account_url(savings_accounts(:one))
    assert_response :success
  end

  test "update modifies account and redirects" do
    patch savings_account_url(savings_accounts(:one)), params: { savings_account: { client_id: clients(:two).id } }
    assert_redirected_to savings_account_path(savings_accounts(:one))
  end

  test "destroy soft-deletes account and redirects" do
    account = savings_accounts(:one)
    delete savings_account_url(account)
    assert_redirected_to savings_accounts_url
    account.reload
    assert_not_nil account.deleted_at
  end
end
