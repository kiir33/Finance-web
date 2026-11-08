require "test_helper"

class ClientTest < ActiveSupport::TestCase
  test "requires client_id and name" do
    client = Client.new
    assert_not client.valid?
    assert_includes client.errors[:client_id], "can't be blank"
    assert_includes client.errors[:name], "can't be blank"
  end

  test "client_id must be unique" do
    duplicate = Client.new(client_id: "101", name: "Dup")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:client_id], "has already been taken"
  end

  test "generates a public_id before create" do
    client = Client.create!(client_id: "501", name: "Public ID Client")
    assert client.public_id.present?
  end

  test "soft delete sets deleted_at" do
    client = clients(:one)
    client.update!(deleted_at: Time.current)
    assert client.deleted_at.present?
    assert_not Client.where(deleted_at: nil).exists?(client.id)
  end
end
