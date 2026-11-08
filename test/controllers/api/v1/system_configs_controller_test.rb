require "test_helper"

module Api
  module V1
    class SystemConfigsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = open_session
        @admin.post api_v1_auth_login_url,
                    params: { email: "admin@example.com", password: "password123" }, as: :json
        @admin_headers = { "Authorization" => "Bearer #{@admin.response.parsed_body["data"]["token"]}" }

        @member = open_session
        @member.post api_v1_auth_login_url,
                     params: { email: "member@example.com", password: "password123" }, as: :json
        @member_headers = { "Authorization" => "Bearer #{@member.response.parsed_body["data"]["token"]}" }
      end

      test "member can read system configs" do
        @member.get api_v1_system_configs_url, headers: @member_headers, as: :json
        @member.assert_response :ok
      end

      test "member cannot create a system config (403)" do
        assert_no_difference -> { SystemConfig.count } do
          @member.post api_v1_system_configs_url,
                       params: { config_key: "test_key", config_value: "1", config_type: "savings" },
                       headers: @member_headers, as: :json
        end
        @member.assert_response :forbidden
      end

      test "admin can create a system config" do
        assert_difference -> { SystemConfig.count }, 1 do
          @admin.post api_v1_system_configs_url,
                      params: { config_key: "test_config_key", config_value: "42", config_type: "loan", description: "test" },
                      headers: @admin_headers, as: :json
        end
        @admin.assert_response :created
      end

      test "admin can update a system config" do
        config = system_configs(:savings_interest_rate)
        @admin.patch api_v1_url(key: config.config_key),
                     params: { config_value: "0.06" }, headers: @admin_headers, as: :json
        @admin.assert_response :ok
        assert_equal "0.06", config.reload.config_value
      end
    end
  end
end
