require 'scoped_cache_keys/version'

module ScopedCacheKeys
  class << self
    # If set, expire_scoped_cache_key will delay expiration by this many seconds
    # globally.
    attr_accessor :expire_scoped_cache_key_delay
  end

  def scoped_cache_key(scope, options = nil)
    base_key = Rails.cache.fetch(build_scoped_cache_key([scope]), options) { Time.now.to_f }
    build_scoped_cache_key [scope, base_key]
  end

  def expire_scoped_cache_key(scope, delay: nil)
    delay ||= ScopedCacheKeys.expire_scoped_cache_key_delay
    key = build_scoped_cache_key(scope)
    if delay
      entry = Rails.cache.read(key)
      Rails.cache.write(key, entry, expires_in: delay) if entry
    else
      Rails.cache.delete(key)
    end
  end

  private

  def build_scoped_cache_key(*scopes)
    "#{self.class.table_name}/#{id}/#{scopes.join('/')}"
  end
end
