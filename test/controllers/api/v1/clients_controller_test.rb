require "test_helper"

module Api
  module V1
    class ClientsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @session = open_session
        @session.post api_v1_auth_login_url,
                      params: { email: "admin@example.com", password: "password123" }, as: :json
        @token = @session.response.parsed_body["data"]["token"]
        @headers = { "Authorization" => "Bearer #{@token}" }
      end

      test "index requires authentication" do
        guest = open_session
        guest.get api_v1_clients_url, as: :json
        guest.assert_response :unauthorized
      end

      test "admin can list non-deleted clients" do
        @session.get api_v1_clients_url, headers: @headers, as: :json
        @session.assert_response :ok
        data = @session.response.parsed_body["data"]
        assert data.is_a?(Array)
        assert_not_empty data
      end

      test "admin can create a client" do
        assert_difference -> { Client.count }, 1 do
          @session.post api_v1_clients_url,
                        params: { client_id: "801", name: "API Client", phone_number: "555-0001", address: "1 Main St" },
                        headers: @headers, as: :json
        end
        @session.assert_response :created
      end

      test "show returns a client by public_id" do
        client = clients(:one)
        @session.get api_v1_client_url(client.public_id), headers: @headers, as: :json
        @session.assert_response :ok
        assert_equal client.public_id, @session.response.parsed_body["data"]["public_id"]
      end

      test "update changes a client" do
        client = clients(:one)
        @session.patch api_v1_client_url(client.public_id),
                       params: { name: "Updated Name" }, headers: @headers, as: :json
        @session.assert_response :ok
        assert_equal "Updated Name", client.reload.name
      end

      test "destroy soft-deletes a client" do
        client = clients(:two)
        assert_difference -> { Client.where(deleted_at: nil).count }, -1 do
          @session.delete api_v1_client_url(client.public_id), headers: @headers, as: :json
        end
        @session.assert_response :ok
        assert client.reload.deleted_at.present?
      end
    end
  end
end
