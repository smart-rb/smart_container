# Changelog
All notable changes to this project will be documented in this file.

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
