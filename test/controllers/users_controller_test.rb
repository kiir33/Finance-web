require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get users_url
    assert_response :success
  end

  test "new renders a form" do
    get new_user_url
    assert_response :success
  end

  test "create adds a user and redirects" do
    assert_difference -> { User.count }, 1 do
      post users_url, params: { user: { email: "newuser@example.com", password: "password123", password_confirmation: "password123", role: "member" } }
    end
    assert_redirected_to user_path(User.last)
  end

  test "show renders user details" do
    get user_url(users(:admin))
    assert_response :success
  end

  test "edit renders a form" do
    get edit_user_url(users(:member))
    assert_response :success
  end

  test "update changes a user and redirects" do
    patch user_url(users(:member)), params: { user: { email: "updated@example.com", lock_version: users(:member).lock_version } }
    assert_redirected_to user_path(users(:member))
    users(:member).reload
    assert_equal "updated@example.com", users(:member).email
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get users_url
    assert_redirected_to new_session_url
  end

  test "member cannot access user management" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get users_url
    assert_redirected_to root_path
  end

  test "concurrent edit with stale lock_version shows conflict" do
    user = users(:member)
    original_lock_version = user.lock_version
    # Simulate another session updating the record first
    user.increment!(:lock_version)

    patch user_url(user), params: { user: { email: "changed@example.com", lock_version: original_lock_version } }
    assert_response :conflict
  end

  test "force_update overwrites concurrent changes" do
    user = users(:member)
    original_lock_version = user.lock_version
    # Simulate another session updating the record first
    user.increment!(:lock_version)

    patch user_url(user), params: { user: { email: "overwritten@example.com", lock_version: original_lock_version, force_update: "true" } }
    assert_redirected_to user_path(user)
    user.reload
    assert_equal "overwritten@example.com", user.email
  end
end
