scoped_cache_keys
=================

Add `scoped_cache_key` / `expire_scoped_cache_key` to your models for caching/sweeping of model-related caches.

Overview
--------

`scoped_cache_keys` enables you to "scope" multiple cache entries together, such that they can be expired
together in a single operation.

This saves the trouble of having to delete several individual cache entries, and improves the consistency
of your cache entries by having them all expire together.

Model-related caches in a Rails application often consist of multiple cache entries, which should be
consistent with each other.

For instance, you might have a cache entry which is a key->value mapping for a model, but another
cache entry which is a value->key mapping.

Install
-------

```bash
gem "scoped_cache_keys"
```

Usage
-----

To use `scoped_cached_keys`, use `include ScopedCacheKeys` in your model declaration:

```ruby
class User < ActiveRecord::Base
  include ScopedCacheKeys
  ...
end
```

### scoped_cache_key ###

The `scoped_cache_key` method returns a key that will change whenever `expire_scoped_cache_key` is called.
The cache key will be scoped to the model object that `scoped_cache_key` is invoked on, along with
whatever scope is passed:

```ruby
  account.scoped_cache_key(:orders)
```

Options: Any caching options that are passed to `Rails.cache` methods may be passed to `scoped_cache_key`.
For example:

```ruby
  account.scoped_cache_key(:orders, expires_in: 10.minutes)
```

The key that is returned can be treated as a "base key," that is, concatenated with other strings to form
other cache keys. All such cache keys will become unreachable, and thus "expired," when
`expire_scoped_cache_key` is called.

### expire_scoped_cache_key ###

The `expire_scoped_cache_key` method will expire a scoped cache key obtained with `scoped_cache_key`.
Example:

```ruby
  account.expire_scoped_cache_key(:orders)
```

Options: The optional `delay` parameter specifies an amount of time to delay before actually expiring
the scoped cache key. Example:

```ruby
  account.expire_scoped_cache_key(:orders, delay: 5.seconds)
```

The `delay` parameter can be useful for contending with database replication lag. When many concurrent 
processes access the scoped cache entries, one or more may immediately try to rebuild the cache
the instant that `expire_scoped_cache_key` completes. This could happen so quickly that the database
replicas may not be caught up with the model changes that were just committed. Alternately, one
could force the models to be queried from the primary database to avoid such race conditions.

The expiration delay may also be set at a global level:

```ruby
    ScopedCacheKeys.expire_scoped_cache_key_delay = 10.seconds
```

### Example ###

```
    <% cache user.scoped_cache_key :products do %>
      ... user.products.each ...
    <% end %>

    <% cache "something-else-" + user.scoped_cache_key(:products) do %>
      ... will also be expired ...
    <% end %>
```

```ruby
    # app/sweepers/product_sweeper.rb
    class ProductSweeper < ActionController::Caching::Sweeper
      observe Product

      def after_save(record)
        record.user.expire_scoped_cache_key :products
      end
    end
```

Author
------
[Zendesk](http://zendesk.com)<br/>
michael@grosser.it<br/>
License: MIT
