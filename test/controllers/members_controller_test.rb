require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get members_url
    assert_response :success
  end

  test "new renders a form" do
    get new_member_url
    assert_response :success
  end

  test "create adds a member and redirects" do
    assert_difference -> { Member.count }, 1 do
      post members_url, params: { member: { member_id: "701", name: "Web Member", phone_number: "555-0001", address: "1 Web St", user_id: users(:member).id } }
    end
    assert_redirected_to member_path(Member.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get members_url
    assert_redirected_to new_session_url
  end

  test "member only sees members linked to their own account" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get members_url
    assert_response :success
    assert_includes response.body, "101"
    assert_not_includes response.body, "102"
  end

  test "member cannot view a member linked to another account" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get member_url(members(:two))
    assert_response :not_found
  end
end
