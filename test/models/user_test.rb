require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "role scopes and predicates" do
    assert users(:admin).admin?
    assert_not users(:admin).member?
    assert users(:member).member?
    assert_not users(:member).admin?
  end

  test "requires email and password" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:password], "can't be blank"
  end

  test "email must be unique" do
    duplicate = User.new(email: "admin@example.com", password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "password must be at least 6 characters" do
    user = User.new(email: "new@example.com", password: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end
end
