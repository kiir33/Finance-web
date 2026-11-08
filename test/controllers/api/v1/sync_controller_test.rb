require "test_helper"

module Api
  module V1
    class SyncControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:admin)
        post api_v1_auth_login_url, params: { email: "admin@example.com", password: "password123" }, as: :json
        @token = response.parsed_body["data"]["token"]
        @headers = { "Authorization" => "Bearer #{@token}" }
      end

      test "download requires authentication" do
        # open_session gives a fresh client without the login cookie from setup
        guest = open_session
        guest.get api_v1_sync_url, as: :json
        guest.assert_response :unauthorized
      end

      test "download returns delta since a timestamp" do
        client = Client.create!(client_id: "901", name: "Sync Test")

        get api_v1_sync_url, params: { since: "1970-01-01T00:00:00Z" }, headers: @headers, as: :json
        assert_response :ok
        changes = response.parsed_body["data"]["changes"]
        assert changes.any? { |c| c["record_type"] == "client" && c["public_id"] == client.public_id }
      end

      test "download excludes changes older than since" do
        Client.create!(client_id: "902", name: "Old Client")
        old = 2.days.ago.iso8601
        get api_v1_sync_url, params: { since: old }, headers: @headers, as: :json
        assert_response :ok
      end

      test "upload applies a create change and returns public_id mapping" do
        temp_id = "temp-client-903"
        post api_v1_sync_url,
             params: { device_id: "device-1",
                       changes: [{ record_type: "client", op: "create", local_temp_id: temp_id,
                                   payload: { client_id: "903", name: "Upload Client" } }] },
             headers: @headers, as: :json
        assert_response :ok
        mappings = response.parsed_body["data"]["mappings"]
        assert mappings.any? { |m| m["local_temp_id"] == temp_id && m["public_id"].present? }
        assert Client.find_by(client_id: "903")
      end

      test "upload detects lock_version conflict and returns 409" do
        client = Client.create!(client_id: "904", name: "Conflict Client")
        original_version = client.lock_version
        client.increment!(:lock_version)

        post api_v1_sync_url,
             params: { device_id: "device-1",
                       changes: [{ record_type: "client", op: "update", public_id: client.public_id,
                                   payload: { name: "Changed", lock_version: original_version } }] },
             headers: @headers, as: :json
        assert_response :conflict
        assert_equal "conflict", response.parsed_body["error"]["code"]
      end

      test "soft delete produces a tombstone in download" do
        client = Client.create!(client_id: "905", name: "Tombstone Client")

        get api_v1_sync_url, params: { since: "1970-01-01T00:00:00Z" }, headers: @headers, as: :json
        create_change = response.parsed_body["data"]["changes"].find { |c| c["public_id"] == client.public_id }
        assert_not create_change["deleted"]

        client.update!(deleted_at: Time.current)
        get api_v1_sync_url, params: { since: "1970-01-01T00:00:00Z" }, headers: @headers, as: :json
        delete_change = response.parsed_body["data"]["changes"].find { |c| c["public_id"] == client.public_id && c["deleted"] }
        assert delete_change, "expected a tombstone for the soft-deleted client"
      end
    end
  end
end
