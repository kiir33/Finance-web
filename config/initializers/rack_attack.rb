# frozen_string_literal: true

class Rack::Attack
  # Throttle login attempts by IP (5 req/min)
  throttle("auth/login", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Throttle sync upload by user (30 req/min)
  throttle("sync/upload", limit: 30, period: 1.minute) do |req|
    if req.path == "/api/v1/sync" && req.post?
      # Try to get user from JWT token
      token = req.env["HTTP_AUTHORIZATION"]&.gsub(/^Bearer /, "")
      if token
        begin
          payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first
          "user:#{payload['user_id']}"
        rescue JWT::DecodeError
          req.ip
        end
      else
        req.ip
      end
    end
  end

  # Throttle sync download by user (60 req/min)
  throttle("sync/download", limit: 60, period: 1.minute) do |req|
    if req.path == "/api/v1/sync" && req.get?
      token = req.env["HTTP_AUTHORIZATION"]&.gsub(/^Bearer /, "")
      if token
        begin
          payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first
          "user:#{payload['user_id']}"
        rescue JWT::DecodeError
          req.ip
        end
      else
        req.ip
      end
    end
  end

  # Throttle password change by user (5 req/min)
  throttle("auth/password_change", limit: 5, period: 1.minute) do |req|
    if req.path == "/api/v1/auth/password-change" && req.post?
      token = req.env["HTTP_AUTHORIZATION"]&.gsub(/^Bearer /, "")
      if token
        begin
          payload = JWT.decode(token, ENV.fetch("API_TOKEN_SECRET"), true, algorithm: "HS256").first
          "user:#{payload['user_id']}"
        rescue JWT::DecodeError
          req.ip
        end
      else
        req.ip
      end
    end
  end

  # Custom response for throttled requests
  self.throttled_response = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: { code: "rate_limited", message: "Too many requests. Please try again later." } }.to_json ]
    ]
  end

  # Allow localhost and tunnel URLs for development
  safelist("allow-localhost") do |req|
    [ "127.0.0.1", "::1", "localhost" ].include?(req.ip)
  end
end

# Only enable Rack::Attack in production and staging, or when explicitly enabled
if Rails.env.production? || Rails.env.staging? || ENV["ENABLE_RACK_ATTACK"] == "true"
  Rails.application.config.middleware.use Rack::Attack
end
