# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the mobile app.
# Origins are read from the CORS_ORIGINS environment variable (comma-separated).
# Defaults include localhost, 127.0.0.1, and common cloudflared tunnel domains.
allowed_origins = ENV.fetch("CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000,https://*.trycloudflare.com").split(",").map(&:strip)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins allowed_origins

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end