require 'scoped_cache_keys/version'

module ScopedCacheKeys
  def scoped_cache_key(scope)
    base_key = Rails.cache.fetch(build_scoped_cache_key([scope])){ Time.now.to_f }
    build_scoped_cache_key [scope, base_key]
  end

  def expire_scoped_cache_key(scope)
    Rails.cache.delete(build_scoped_cache_key(scope))
  end

  private

  def build_scoped_cache_key(*scopes)
    "#{self.class.table_name}/#{id}/#{scopes.join('/')}"
  end
end
