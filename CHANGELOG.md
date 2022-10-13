# Changelog
All notable changes to this project will be documented in this file.

## [0.10.0] - 2022-10-14
### Changed
- Simple `Mutex`-based locks was replaced with `SmartCore::Engine::ReadWriteLock` in order to decrease
  context switching during method resolving inside RubyVM (to reduce thread locks when it is not necessary);
- Development progress:
  - Minimal ruby version - **2.5**;
  - Updated development dependencies;
  - Updated `smart_engine` dependency (`~> 0.11` -> `~> 0.17`);


## [0.9.0] - 2020-01-17
### Added
- Support for **Ruby@3**;
- Updated development dependencies;

### Changed
- No more TravisCI (todo: migrate to Github Actions);
- Minimal `smart_engine` version: **0.11.0** (in order to support **Ruby@3**);

## [0.8.1] - 2020-07-09
### Changed
- *Core*
  - refactored `SmartCore::Container::Entities::NamespaceBuilder` and `SmartCore::Container::Entities::DependencyBuilder`
    (from stateful-based logic on instances to stateless-based logic on modules);

### Fixed
- Subscription to the nested dependency changement doesn't work
  (incomplete nested dependency path in watcher notification);

## [0.8.0] - 2020-07-08
### Added
- An ability to observe dependency re-registrations:
  - `#observe(path, &observer) # => observer object` - listen specific dependency path;
  - `#unobserve(observer)` - unsubscribe concrete observer object;
  - `#clear_observers(path = nil)` - unsubscribe specific listenr or all listeners (`nil` parameter);

## [0.7.0] - 2020-06-20
### Added
- `SmartCore::Container.define {}` - an ability to avoid explicit class definition that allows
  to create container instances from an anonymous container class imidietly

## [0.6.0] - 2020-01-12
### Added
- Missing memoization flag `:memoize` for runtime-based dependency registration:
  - `memoize: false` by default;
  - signature: `SmartCore::Container#register(dependency_name, memoize: false, &dependency)`

## [0.5.0] - 2020-01-07
### Added
- Key predicates (`#key?(key)`, `#dependency?(path, memoized: nil/true/false)`, `#namespace?(path)`);

## [0.4.0] - 2020-01-06
### Added
- `#keys(all_variants: false)` - return a list of dependency keys
  (`all_variants: true` is mean "including namespace kaeys");
- `#each_dependency(yield_all: false) { |key, value| }` - iterate over conteiner's dependencies
  (`yield_all: true` will include nested containers to iteration process);
### Fixed
- `SmartCore::Container::ResolvingError` class has incorrect message attribute name;

## [0.3.0] - 2020-01-05
### Changed
- Dependency resolving is not memoized by default (previously: totally memoized 😱);

## [0.2.0] - 2020-01-05
### Changed
- (Private API (`SmartCore::Container::RegistryBuilder`)) improved semantics:
  - `build_state` is renamed to `initialise`;
  - `build_definitions` is renamed to `define`;
- (Public API) Support for memoized dependencies (all dependencies are memoized by default);

## [0.1.0] - 2020-01-02

- Release :)
