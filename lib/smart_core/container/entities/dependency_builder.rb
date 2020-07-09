# frozen_string_literal: true

# @api private
# @since 0.1.0
# @version 0.8.1
module SmartCore::Container::Entities::DependencyBuilder
  class << self
    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @param memoize [Boolean]
    # @return [SmartCore::Container::Entities::Dependency]
    #
    # @api private
    # @since 0.1.0
    # @version 0.8.1
    def build(dependency_name, dependency_definition, memoize)
      if memoize
        build_memoized_dependency(dependency_name, dependency_definition)
      else
        build_original_dependency(dependency_name, dependency_definition)
      end
    end

    private

    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @return [SmartCore::Container::Entities::Dependency]
    #
    # @api private
    # @since 0.8.1
    def build_memoized_dependency(dependency_name, dependency_definition)
      SmartCore::Container::Entities::MemoizedDependency.new(dependency_name, dependency_definition)
    end

    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @return [SmartCore::Container::Entities::Dependency]
    #
    # @api private
    # @since 0.8.1
    def build_original_dependency(dependency_name, dependency_definition)
      SmartCore::Container::Entities::Dependency.new(dependency_name, dependency_definition)
    end
  end
end
