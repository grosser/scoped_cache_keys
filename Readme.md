Add scoped_cache_key / expire_scoped_cache_key to your models for caching/sweeping of model-related caches.

Install
=======
    sudo gem install scoped_cache_keys
Or

    rails plugin install git://github.com/grosser/scoped_cache_keys.git

Usage
=====

Gives you a key that will change whenever expire_scoped_cache_key is called.

    <% cache user.scoped_cache_key :products do %>
      ... user.products.each ...
    <% end %>

    <% cache "something-else-" + user.scoped_cache_key :products %>
      ... will also be expired ...
    <% end %>

    # app/sweepers/product_sweeper.rb
    class ProductSweeper < ActionController::Caching::Sweeper
      observe Product

      def after_save(record)
        record.user.expire_scoped_cache_key :products
      end
    end

Author
======
[Zendesk](http://zendesk.com)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://secure.travis-ci.org/grosser/scoped_cache_keys.png)](http://travis-ci.org/grosser/scoped_cache_keys)
