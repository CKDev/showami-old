Sidekiq.configure_server do |config|
  config.redis = { namespace: "showami" }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: "showami" }
end
