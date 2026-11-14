module Api
  module V1
    class MembersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @session = open_session
        @session.post api_v1_auth_login_url,
                      params: { email: "admin@example.com", password: "password123" }, as: :json
        @token = @session.response.parsed_body["data"]["token"]
        @headers = { "Authorization" => "Bearer #{@token}" }
      end

      test "index requires authentication" do
        guest = open_session
        guest.get api_v1_members_url, as: :json
        guest.assert_response :unauthorized
      end

      test "admin can list non-deleted members" do
        @session.get api_v1_members_url, headers: @headers, as: :json
        @session.assert_response :ok
        data = @session.response.parsed_body["data"]
        assert data.is_a?(Array)
        assert_not_empty data
      end

      test "admin can create a member" do
        assert_difference -> { Member.count }, 1 do
          @session.post api_v1_members_url,
                        params: { member_id: "801", name: "API Member", phone_number: "555-0001", address: "1 Main St", user_id: users(:member).id },
                        headers: @headers, as: :json
        end
        @session.assert_response :created
      end

      test "show returns a member by public_id" do
        member = members(:one)
        @session.get api_v1_member_url(member.public_id), headers: @headers, as: :json
        @session.assert_response :ok
        assert_equal member.public_id, @session.response.parsed_body["data"]["public_id"]
      end

      test "update changes a member" do
        member = members(:one)
        @session.patch api_v1_member_url(member.public_id),
                       params: { name: "Updated Name" }, headers: @headers, as: :json
        @session.assert_response :ok
        assert_equal "Updated Name", member.reload.name
      end

      test "destroy soft-deletes a member" do
        member = members(:two)
        assert_difference -> { Member.where(deleted_at: nil).count }, -1 do
          @session.delete api_v1_member_url(member.public_id), headers: @headers, as: :json
        end
        @session.assert_response :ok
        assert member.reload.deleted_at.present?
      end
    end
  end
end
