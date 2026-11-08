require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index when signed in" do
    post session_url, params: { email: "admin@example.com", password: "password123" }
    get home_index_url
    assert_response :success
  end

  test "redirects to login when not signed in" do
    get home_index_url
    assert_response :redirect
    assert_redirected_to new_session_path
  end
end
