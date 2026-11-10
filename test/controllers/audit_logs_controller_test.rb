require "test_helper"

class AuditLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get audit_logs_url
    assert_response :success
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get audit_logs_url
    assert_redirected_to new_session_url
  end

  test "member is redirected away from audit logs" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get audit_logs_url
    assert_redirected_to root_path
  end
end
