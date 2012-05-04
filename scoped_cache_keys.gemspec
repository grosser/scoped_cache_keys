$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
name = "scoped_cache_keys"
require "#{name}/version"

Gem::Specification.new name, ScopedCacheKeys::VERSION do |s|
  s.summary = "Add scoped_cache_key / expire_scoped_cache_key to your models for caching/sweeping of model-related caches + touch_if_necessary"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'
end
