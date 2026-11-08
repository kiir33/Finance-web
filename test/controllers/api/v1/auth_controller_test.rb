require "test_helper"

module Api
  module V1
    class AuthControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:admin)
        @member = users(:member)
      end

      test "login issues a JWT for a valid admin user" do
        post api_v1_auth_login_url, params: { email: "admin@example.com", password: "password123" }, as: :json
        assert_response :ok
        json = response.parsed_body
        assert json["data"]["token"].present?
        assert_equal "admin", json["data"]["user"]["role"]
      end

      test "login issues a JWT for a valid member user" do
        post api_v1_auth_login_url, params: { email: "member@example.com", password: "password123" }, as: :json
        assert_response :ok
        json = response.parsed_body
        assert json["data"]["token"].present?
        assert_equal "member", json["data"]["user"]["role"]
      end

      test "login rejects invalid credentials" do
        post api_v1_auth_login_url, params: { email: "admin@example.com", password: "wrong" }, as: :json
        assert_response :unauthorized
        assert_equal "invalid_credentials", response.parsed_body["error"]["code"]
      end

      test "protected API endpoints require authentication" do
        get api_v1_clients_url, as: :json
        assert_response :unauthorized
      end

      test "authenticated admin can access clients index" do
        post api_v1_auth_login_url, params: { email: "admin@example.com", password: "password123" }, as: :json
        token = response.parsed_body["data"]["token"]
        get api_v1_clients_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json
        assert_response :ok
      end

      test "logout revokes the token" do
        post api_v1_auth_login_url, params: { email: "admin@example.com", password: "password123" }, as: :json
        token = response.parsed_body["data"]["token"]
        post api_v1_auth_logout_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json
        assert_response :ok
      end

      test "password change requires authentication and updates password" do
        post api_v1_auth_login_url, params: { email: "member@example.com", password: "password123" }, as: :json
        token = response.parsed_body["data"]["token"]
        post api_v1_auth_password_change_url,
              params: { password: "newpassword123", password_confirmation: "newpassword123" },
              headers: { "Authorization" => "Bearer #{token}" }, as: :json
        assert_response :ok
      end
    end
  end
end
