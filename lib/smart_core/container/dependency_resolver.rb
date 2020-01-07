# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DependencyResolver
  require_relative 'dependency_resolver/route'

  # @return [String]
  #
  # @api private
  # @since 0.4.0
  PATH_PART_SEPARATOR = '.'

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
    # @param key [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.5.0
    def key?(container, key)
      extract(container, key)
      true
    rescue SmartCore::Container::ResolvingError
      false
    end

    # @param namespace_path [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.5.0
    def namespace?(container, namespace_path)
      extract(container, namespace_path).is_a?(SmartCore::Container::Entities::Namespace)
    rescue SmartCore::Container::ResolvingError
      false
    end

    # @param dependency_path [String, Symbol]
    # @option memoized [NilClass, Boolean]
    # @return [Boolean]
    #
    # @api private
    # @since 0.5.0
    def dependency?(container, dependency_path, memoized: nil)
      entity = extract(container, dependency_path)

      case
      when memoized.nil?
        entity.is_a?(SmartCore::Container::Entities::Dependency)
      when !!memoized == true
        entity.is_a?(SmartCore::Container::Entities::MemoizedDependency)
      when !!memoized == false
        entity.is_a?(SmartCore::Container::Entities::Dependency) &&
          !entity.is_a?(SmartCore::Container::Entities::MemoizedDependency)
      end
    rescue SmartCore::Container::ResolvingError
      false
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
    def resolve(container, dependency_path)
      entity = container
      Route.build(dependency_path).each do |cursor|
        entity = entity.registry.resolve(cursor.current_path)
        prevent_ambigous_resolving!(cursor, entity)
        entity = entity.reveal
      end
      entity
    rescue SmartCore::Container::ResolvingError => error
      process_resolving_error(dependency_path, error)
    end

    private

    # @param container [SmartCore::Container]
    # @param entity_path [String, Symbol]
    # @return [SmartCore::Container::Entities::Base]
    #
    # @api private
    # @since 0.5.0
    def extract(container, entity_path)
      resolved_entity = container
      extracted_entity = container

      Route.build(entity_path).each do |cursor|
        resolved_entity = resolved_entity.registry.resolve(cursor.current_path)
        prevent_cursor_overflow!(cursor, resolved_entity)
        extracted_entity = resolved_entity
        resolved_entity = resolved_entity.reveal
      end

      extracted_entity
    end

    # @param cursor [SmartCore::Container::DependencyResolver::Route::Cursor]
    # @param entity [SmartCore::Container::Entities::Base]
    # @return [void]
    #
    # @raise [SmartCore::Container::ResolvingError]
    #
    # @api private
    # @since 0.5.0
    # @version 0.5.0
    def prevent_cursor_overflow!(cursor, entity)
      if !cursor.last? && !entity.is_a?(SmartCore::Container::Entities::Namespace)
        raise(
          SmartCore::Container::ResolvingError.new(
            'Trying to resolve nonexistent dependency',
            path_part: cursor.current_path
          )
        )
      end
    end

    # @param cursor [SmartCore::Container::DependencyResolver::Route::Cursor]
    # @param entity [SmartCore::Container::Entities::Base]
    # @return [void]
    #
    # @raise [SmartCore::Container::ResolvingError]
    #
    # @api private
    # @since 0.5.0
    def prevent_ambigous_resolving!(cursor, entity)
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
      full_dependency_path = Route.build_path(error.path_part)
      message = "#{error.message} (incorrect path: \"#{full_dependency_path}\")"
      raise(SmartCore::Container::ResolvingError.new(message, path_part: full_dependency_path))
    end
  end
end
