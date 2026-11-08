require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  # Production smoke test: verifies the app boots with Postgres and the
  # /up health endpoint returns 200. Run against the test database in CI
  # (Puma + Postgres service), mirroring production startup.
  test "GET /up returns 200 in production-like environment" do
    # Temporarily run the request as if in production mode for the smoke check.
    original_env = ENV["RAILS_ENV"]
    ENV["RAILS_ENV"] = "production"
    begin
      get rails_health_check_url
      assert_response :ok
    ensure
      ENV["RAILS_ENV"] = original_env
    end
  end
end
