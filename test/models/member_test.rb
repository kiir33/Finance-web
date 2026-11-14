require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "requires member_id and name" do
    member = Member.new
    assert_not member.valid?
    assert_includes member.errors[:member_id], "can't be blank"
    assert_includes member.errors[:name], "can't be blank"
  end

  test "member_id must be unique" do
    duplicate = Member.new(member_id: "101", name: "Dup")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:member_id], "has already been taken"
  end

  test "generates a public_id before create" do
    member = Member.create!(member_id: "501", name: "Public ID Member", user: users(:member))
    assert member.public_id.present?
  end

  test "soft delete sets deleted_at" do
    member = members(:one)
    member.update!(deleted_at: Time.current)
    assert member.deleted_at.present?
    assert_not Member.where(deleted_at: nil).exists?(member.id)
  end
end
