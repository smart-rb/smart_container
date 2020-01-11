# Changelog
All notable changes to this project will be documented in this file.

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
