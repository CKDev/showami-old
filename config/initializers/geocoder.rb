Geocoder.configure(
  # Caching
  cache: Redis.new,
  cache_prefix: "geocoder_showami"
)
