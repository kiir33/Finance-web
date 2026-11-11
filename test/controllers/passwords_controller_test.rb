require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "should get change password page with auth layout (no sidebar/nav) when signed in" do
    post session_url, params: { email: @admin.email, password: "password123" }

    get edit_password_url
    assert_response :success

    # Auth layout: no sidebar, no navigation, no user menu
    assert_select "aside#sidebar", false
    assert_select "nav", false
    assert_select "[aria-label='Main navigation']", false
    assert_select ".sidebar-link", false

    # Auth UI present
    assert_select "h1", text: "Change Password"
    assert_select ".auth-card"
    assert_select "form[action='/password/change']"
    assert_select "input[type='password'][autocomplete='new-password'][required]"
    assert_select "button[aria-label='Show password']"
  end

  test "should redirect to login when not signed in" do
    get edit_password_url
    assert_redirected_to new_session_url
  end

  test "should update password when signed in" do
    post session_url, params: { email: @admin.email, password: "password123" }

    patch password_url, params: {
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to root_url
  end

  test "should show errors when passwords do not match" do
    post session_url, params: { email: @admin.email, password: "password123" }

    patch password_url, params: {
      password: "newpassword123",
      password_confirmation: "different"
    }
    assert_response :unprocessable_entity
    assert_select "h1", text: "Change Password"
  end
end
