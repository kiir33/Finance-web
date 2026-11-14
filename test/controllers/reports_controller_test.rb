require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get reports_url
    assert_response :success
  end

  test "shows treasury summary" do
    get reports_url
    assert_select "h3", text: "Group Treasury"
  end

  test "shows member count" do
    get reports_url
    assert_select "h3", text: "Total Members"
  end

  test "shows savings summary" do
    get reports_url
    assert_select "h3", text: "Savings Summary"
  end

  test "redirects to login when not signed in" do
    delete destroy_session_url
    get reports_url
    assert_redirected_to new_session_url
  end

  test "member cannot access reports" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get reports_url
    assert_redirected_to root_path
  end
end
