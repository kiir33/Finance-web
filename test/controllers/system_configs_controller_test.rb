require "test_helper"

class SystemConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get system_configs_url
    assert_response :success
  end

  test "new renders a form" do
    get new_system_config_url
    assert_response :success
  end

  test "create adds a system config and redirects" do
    assert_difference -> { SystemConfig.count }, 1 do
      post system_configs_url, params: { system_config: { config_key: "test_key", config_value: "test_value", config_type: "savings", description: "Test config" } }
    end
    assert_redirected_to system_config_path(SystemConfig.last)
  end

  test "show renders for a signed-in admin" do
    config = system_configs(:savings_interest_rate)
    get system_config_url(config.config_key)
    assert_response :success
  end

  test "edit renders form for admin" do
    config = system_configs(:savings_interest_rate)
    get edit_system_config_url(config.config_key)
    assert_response :success
  end

  test "update modifies config and redirects" do
    config = system_configs(:savings_interest_rate)
    patch system_config_url(config.config_key), params: { system_config: { config_value: "updated_value" } }
    assert_redirected_to system_config_path(config.config_key)
  end

  test "destroy deletes config and redirects" do
    config = system_configs(:loan_max_amount)
    delete system_config_url(config.config_key)
    assert_redirected_to system_configs_url
    assert_nil SystemConfig.find_by(config_key: config.config_key)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get system_configs_url
    assert_redirected_to new_session_url
  end

  test "member can read system configs index" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get system_configs_url
    assert_response :success
  end

  test "member can read a system config" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    config = system_configs(:savings_interest_rate)
    get system_config_url(config.config_key)
    assert_response :success
  end

  test "member cannot create system config" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    post system_configs_url, params: { system_config: { config_key: "test", config_value: "value", config_type: "savings" } }
    assert_redirected_to root_path
  end
end
