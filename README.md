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

## Table of cotnents

- [Functionality](#functionality)
  - [container class creation](#container-class-creation)
  - [mixining to any class or module](#mixining-to-any-class-or-module)
  - [container instantiation and dependency resolving](#container-instantiation-and-dependency-resolving)
  - [runtime-level dependency/namespace registration](#runtime-level-dependencynamespace-registration)
  - [container keys (dependency names)](#container-keys-dependency-names)
  - [key predicates](#key-predicates)
  - [state freeze](#state-freeze)
  - [reloading](#reloading)
  - [hash tree](#hash-tree)
  - [explicit class definition](#explicit-class-definition)
  - [dependency changement observing](#dependency-changement-observing)
- [Roadmap](#roadmap)

---

## Functionality

#### container class creation

```ruby
class Container < SmartCore::Container
  namespace(:database) do # support for namespaces
    register(:resolver, memoize: true) { SomeDatabaseResolver.new } # dependency registration

    namespace(:cache) do # support for nested naespaces
      register(:memcached, memoize: true) { MemcachedClient.new }
      register(:redis, memoize: true) { RedisClient.new }
    end
  end

  # root dependencies
  register(:logger, memoize: true) { Logger.new(STDOUT) }

  # dependencies are not memoized by default (memoize: false)
  register(:random) { rand(1000) }
end
```

---

#### mixining to any class or module

```ruby
# full documentaiton is coming;

class Application
  include SmartCore::Container::Mixin

  dependencies do
    namespace(:database) do
      register(:cache) { MemcachedClient.new }
    end
  end
end

# access:
Application.container
Application.new.container # NOTE: the same instance as Application.container
```

---

#### container instantiation and dependency resolving

```ruby
container = Container.new # create container instance
```

```ruby
container['database.resolver'] # => #<SomeDatabaseResolver:0x00007f0f0f1d6332>
container['database.cache.redis'] # => #<RedisClient:0x00007f0f0f1d0158>
container['logger'] # => #<Logger:0x00007f5f0f2f0158>

container.resolve('logger') # #resolve(path) is an alias for #[](path)

# non-memoized dependency
container['random'] # => 352
container['random'] # => 57

# trying to resolve a namespace as dependency
container['database'] # => SmartCore::Container::ResolvingError

# but you can fetch any depenendency type (internal containers and values) via #fetch
container.fetch('database') # => SmartCore::Container (nested container)
container.fetch('database.resolver') # => #<SomeDatabaseResolver:0x00007f0f0f1d6332>
```

---

#### runtime-level dependency/namespace registration

```ruby
container.namespace(:api) do
  register(:provider) { GoogleProvider } # without memoization
end

container.register('game_api', memoize: true) { 'overwatch' } # with memoization

container['api.provider'] # => GoogleProvider
container['game_api'] # => 'overwatch'
```

---

#### container keys (dependency names):

```ruby
# get dependnecy keys (only dependencies)
container.keys
# => result:
[
  'database.resolver',
  'database.cache.memcached',
  'database.cache.redis',
  'logger',
  'random'
]
```
```ruby
# get all keys (namespaces and dependencies)
container.keys(all_variants: true)
# => result:
[
  'database', # namespace
  'database.resolver',
  'database.cache', # namespace
  'database.cache.memcached',
  'database.cache.redis',
  'logger',
  'random'
]
```

---

#### key predicates

- `key?(key)` - has dependency or namespace?
- `namespace?(path)` - has namespace?
- `dependency?(path)` - has dependency?
- `dependency?(path, memoized: true)` - has memoized dependency?
- `dependency?(path, memoized: false)` - has non-memoized dependency?

```ruby
container.key?('database') # => true
container.key?('database.cache.memcached') # => true

container.dependency?('database') # => false
container.dependency?('database.resolver') # => true

container.namespace?('database') # => true
container.namespace?('database.resolver') # => false

container.dependency?('database.resolver', memoized: true) # => true
container.dependency?('database.resolver', memoized: false) # => false

container.dependency?('random', memoized: true) # => false
container.dependency?('random', memoized: false) # => true
```

---

#### state freeze

- state freeze (`#freeze!`, `.#frozen?`):

```ruby
# documentation is coming;
```

---

#### reloading

- reloading (`#reload!):

```ruby
# documentation is coming;
```

---

#### hash tree

- hash tree (`#hash_tree`, `#hash_tree(resolve_dependencies: true)`):

```ruby
# documentation is coming`;
```

---

#### explicit class definition

- `SmartCore::Container.define` - avoid explicit class definition (allows to create container instance from an anonymous container class immidietly):

```ruby
# - create from empty container class -

AppContainer = SmartCore::Container.define do
  namespace :database do
    register(:logger) { Logger.new }
  end
end # => an instance of Class<SmartCore::Container>

AppContainer.resolve('database.logger') # => #<Logger:0x00007f5f0f2f0158>
AppContainer['database.logger'] # => #<Logger:0x00007f5f0f2f0158>
```

```ruby
# - create from another container class with a custom sub-definitions -

class BasicContainer < SmartCore::Container
  namespace(:api) do
    register(:client) { Kickbox.new }
  end
end

AppContainer = BasicContainer.define do
  register(:db_driver) { Sequel }
end
# --- or ---
AppContainer = SmartCore::Container.define(BasicContainer) do
  register(:db_driver) { Sequel }
end

AppContainer['api.client'] # => #<Kickbox:0x00007f5f0f2f0158> (BasicContainer dependency)
AppContainer['db_driver'] # => Sequel (AppContainer dependency)
```

---

#### dependency changement observing

- features and limitations:
  - you can subscribe only on container instances (on container instance changements);
  - at this moment only the full entity path patterns are supported (pattern-based pathes are not supported yet);
  - you can subscribe on namespace changements (when the full namespace is re-registered) and dependency changement (when some dependency has been changed);
  - `#observe(path, &observer) => observer` - subscribe a custom block to dependency changement events (your proc will be invoked with `|path, container|` attributes);
  - `#unobserve(observer)` - unsubscribe concrete observer from dependency observing (returns `true` (unsubscribed) or `false` (nothing to unsubscribe));
  - `#clear_observers(entity_path = nil)` - unsubscribe all observers from concrete path or from all pathes (`nil` parameters);
- aliases:
  - `#observe` => `#subscribe`;
  - `#unobserve` => `#unsubscribe`;
  - `#clear_observers` => `#clear_listeners`;

```ruby
container = SmartCore::Container.define do
  namespace(:database) do
    register(:stats) { 'stat_db' }
  end
end
```

```ruby
# observe entity change
entity_observer = container.observe('database.stats') do |dependency_path, container|
  puts "changed => '#{container[dependency_path]}'"
end

# observe namespace change
namespace_observer = container.observe('database') do |namespace_path, container|
  puts "changed => '#{namespace_path}'"
end
```

```ruby
container.register('database.stats') { 'kek' } # => invokes entity_observer and outputs "changed! => 'kek'"
container.namespace('database') {} # => invoks namespace_observer and outputs "changed => 'database'"

container.unobserve(observer) # unsubscribe entity_observer from dependency changement observing;
container.clear_observers # unsubscribe all observers

container.register('database.stats') { 'kek' } # no one to listen this changement... :)
container.namespace('database') {} # no one to listen this changement... :)
```

---

## Roadmap

- pattern-based pathes in dependency changement observing;

```ruby
container.observe('path.*') { puts 'kek!' } # subscribe to all changements in `path` namespace;
```

- support for instant dependency registration:

```ruby
# common (dynamic) way:
register('dependency_name') { dependency_value }

# instant way:
register('dependency_name', dependency_value)
```

- support for memoization ignorance during dependency resolving:

```ruby
resolve('logger', :allocate) # Draft
```

- container composition;

- support for fallback block in `.resolve` operation (similar to `Hash#fetch` works);

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
