Add scoped_cache_key / expire_scoped_cache_key to your models for caching/sweeping of model-related caches.

Install
=======

```bash
gem "scoped_cache_keys"
```

Usage
=====

Gives you a key that will change whenever expire_scoped_cache_key is called.

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
======
[Zendesk](http://zendesk.com)<br/>
michael@grosser.it<br/>
License: MIT
