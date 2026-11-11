require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "should get new login page with auth layout (no sidebar/nav)" do
    get new_session_url
    assert_response :success

    # Auth layout: no sidebar, no navigation, no user menu
    assert_select "aside#sidebar", false
    assert_select "nav", false
    assert_select "[aria-label='Main navigation']", false
    assert_select ".sidebar-link", false

    # Auth UI present
    assert_select "h1", text: "Log in"
    assert_select ".auth-card"
    assert_select "form[action='/login']"
    assert_select "input[type='email'][autocomplete='username'][required]"
    assert_select "input[type='password'][autocomplete='current-password'][required]"
    assert_select "button[aria-label='Show password']"
  end

  test "should sign in and redirect to root" do
    post session_url, params: { email: @admin.email, password: "password123" }
    assert_redirected_to root_url
    follow_redirect!
    assert_select "h1", text: /Dashboard/
  end

  test "should show alert on invalid credentials and stay on login page" do
    post session_url, params: { email: "nonexistent@example.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_select "div[role='alert']", text: /Invalid email or password/
    assert_select "h1", text: "Log in"
  end

  test "should sign out and redirect to login" do
    post session_url, params: { email: @admin.email, password: "password123" }
    delete destroy_session_url
    assert_redirected_to new_session_url
  end
end
