require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get clients_url
    assert_response :success
  end

  test "new renders a form" do
    get new_client_url
    assert_response :success
  end

  test "create adds a client and redirects" do
    assert_difference -> { Client.count }, 1 do
      post clients_url, params: { client: { client_id: "701", name: "Web Client", phone_number: "555-0001", address: "1 Web St", user_id: users(:member).id } }
    end
    assert_redirected_to client_path(Client.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get clients_url
    assert_redirected_to new_session_url
  end

  test "member only sees clients linked to their own account" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get clients_url
    assert_response :success
    assert_includes response.body, "101"
    assert_not_includes response.body, "102"
  end

  test "member cannot view a client linked to another account" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get client_url(clients(:two))
    assert_response :not_found
  end
end
