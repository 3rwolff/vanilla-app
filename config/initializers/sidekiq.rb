# frozen_string_literal: true

if Rails.env.production?
  redis_url = ENV["REDIS_URL"]
else
  redis_url = "redis://127.0.0.1:6379/0"
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
