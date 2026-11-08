# Rate limiting for auth and sync endpoints.
class Rack::Attack
  # Throttle login endpoint
  throttle("logins/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Throttle sync endpoint
  throttle("sync/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/sync" && req.post?
  end

  # Throttle all API endpoints generally
  throttle("api/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/")
  end

  # Custom response for throttled requests
  self.throttled_responder = ->(req) {
    [ 429,
      { "Content-Type" => "application/json" },
      [{ error: { code: "rate_limited", message: "Too many requests. Please try again later." } }.to_json]
    ]
  }
end
