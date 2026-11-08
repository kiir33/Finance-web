require "test_helper"

class GroupAccountsControllerTest < ActionDispatch::IntegrationTest
  test "index redirects to the singleton treasury for an admin" do
    post session_url, params: { email: "admin@example.com", password: "password123" }

    get group_accounts_url
    assert_redirected_to group_account_path(GroupAccount.first)
  end

  test "members are redirected away from the treasury" do
    post session_url, params: { email: "member@example.com", password: "password123" }

    get group_accounts_url
    assert_redirected_to root_path
  end
end
