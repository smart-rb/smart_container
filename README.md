# SmartCore::Container &middot; [![Gem Version](https://badge.fury.io/rb/smart_container.svg)](https://badge.fury.io/rb/smart_container) [![Build Status](https://travis-ci.org/smart-rb/smart_container.svg?branch=master)](https://travis-ci.org/smart-rb/smart_container)

Thread-safe semanticaly-defined IoC/DI Container.

---

## Installation

```ruby
gem 'smart_container'
```

```shell
bundle install
# --- or ---
gem install smart_container
```

```ruby
require 'smart_core/container'
```

---

## Synopsis (demo)

```ruby
class Container < SmartCore::Container
  namespace(:database) do # support for namespaces
    register(:resolver) { SomeDatabaseResolver.new } # dependency registration

    namespace(:cache) do # support for nested naespaces
      register(:memcached) { MemcachedClient.new }
      register(:redis) { RedisClient.new }
    end
  end

  # root dependencies
  register(:logger) { Logger.new(STDOUT) }

  # do not memoize registered object
  register(:random, memoize: false) { rand(1000) }
end

container = Container.new # create container instance

container['database.resolver'] # => #<SomeDatabaseResolver:0x00007f0f0f1d6332>
container['database.cache.redis'] # => #<RedisClient:0x00007f0f0f1d0158>
container['logger'] # => #<Logger:0x00007f5f0f2f0158>

# non-memoized dependency
container['random'] # => 352
container['random'] # => 57
```

---

## Contributing

- Fork it ( https://github.com/smart-rb/smart_container/fork )
- Create your feature branch (`git checkout -b feature/my-new-feature`)
- Commit your changes (`git commit -am '[feature_context] Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

Released under MIT License.

## Authors

[Rustam Ibragimov](https://github.com/0exp)
