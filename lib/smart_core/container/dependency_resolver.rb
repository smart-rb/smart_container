# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DependencyResolver
  require_relative 'dependency_resolver/route'

  class << self
    # @param container [SmartCore::Container]
    # @param dependency_path [String, Symbol]
    # @return [SmartCore::Container, Any]
    #
    # @see SmartCore::Container::Registry#resolve
    # @see SmartCore::Container::Entities::Namespace#reveal
    # @see SmartCore::Container::Entities::Dependency#reveal
    #
    # @api private
    # @since 0.1.0
    def fetch(container, dependency_path)
      container.registry.resolve(dependency_path).reveal
    end

    # @param container [SmartCore::Container]
    # @param dependency_path [String, Symbol]
    # @return [SmartCore::Container, Any]
    #
    # @see SmartCore::Container::Registry#resolve
    # @see SmartCore::Container::Entities::Namespace#reveal
    # @see SmartCore::Container::Entities::Dependency#reveal
    #
    # @raise [SmartCore::Container::ResolvingError]
    #
    # @api private
    # @since 0.1.0
    # @version 0.1.0
    def resolve(container, dependency_path)
      entity = container
      Route.build(dependency_path).each do |cursor|
        entity = entity.registry.resolve(cursor.current_path)
        prevent_cursor_overflow!(cursor, entity)
        entity = entity.reveal
      end
      entity
    rescue SmartCore::Container::ResolvingError => error
      process_resolving_error(dependency_path, error)
    end

    private

    # @param cursor [SmartCore::Container::DependencyResolver::Route::Cursor]
    # @param entity [SmartCore::Container::Entities::Base]
    # @return [void]
    #
    # @raise [SmartCore::Container::ResolvingError]
    #
    # @api private
    # @since 0.1.0
    def prevent_cursor_overflow!(cursor, entity)
      if cursor.last? && entity.is_a?(SmartCore::Container::Entities::Namespace)
        raise(
          SmartCore::Container::ResolvingError.new(
            'Trying to resolve a namespace as a dependency',
            path_part: cursor.current_path
          )
        )
      end

      if !cursor.last? && entity.is_a?(SmartCore::Container::Entities::Dependency)
        raise(
          SmartCore::Container::ResolvingError.new(
            'Trying to resolve nonexistent dependency',
            path_part: cursor.current_path
          )
        )
      end
    end

    # @param dependency_path [String, Symbol]
    # @param error [SmartCore::Container::ResolvingError]
    # @return [void]
    #
    # @raise [SmartCore::Container::ResolvingError]
    #
    # @api private
    # @since 0.1.0
    def process_resolving_error(dependency_path, error)
      full_dependency_path = Route.build_path(dependency_path, error.path_part)
      raise(SmartCore::Container::ResolvingError.new(<<~MESSAGE, path_part: full_dependency_path))
        #{error.message} (incorrect path: "#{full_dependency_path}")
      MESSAGE
    end
  end
end
