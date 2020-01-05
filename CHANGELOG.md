# Changelog
All notable changes to this project will be documented in this file.

## [0.2.0] - 202-01-05
### Changed
- (Private API (`SmartCore::Container::RegistryBuilder`)) improved semantics:
  - `build_state` is renamed to `initialise`;
  - `build_definitions` is renamed to `define`;
- (Public API) Support for memoized dependencies (all dependencies are memoized by default)
  ```ruby
  class MyContainer < SmartCore::Container
    namespace(:some_naespace) do
      # memoized by default
      register(:random_number) { rand(1000) }
      # explicit memoization
      register(:random_number, memoized: true) { rand(1000) }

      # register non-memoizable dependency
      register(:random_number, memoized: false) { rand(1000) }
    end
  end
  ```

## [0.1.0] - 2020-01-02

- Release :)
