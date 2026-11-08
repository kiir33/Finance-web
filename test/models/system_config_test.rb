require "test_helper"

class SystemConfigTest < ActiveSupport::TestCase
  test "requires config_key, config_value and config_type" do
    config = SystemConfig.new
    assert_not config.valid?
    assert_includes config.errors[:config_key], "can't be blank"
    assert_includes config.errors[:config_value], "can't be blank"
    assert_includes config.errors[:config_type], "can't be blank"
  end

  test "config_type must be savings or loan" do
    config = SystemConfig.new(config_key: "x", config_value: "1", config_type: "invalid")
    assert_not config.valid?
    assert_includes config.errors[:config_type], "is not included in the list"
  end

  test "config_key must be unique" do
    duplicate = SystemConfig.new(config_key: "savings_interest_rate", config_value: "1", config_type: "savings")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:config_key], "has already been taken"
  end
end
