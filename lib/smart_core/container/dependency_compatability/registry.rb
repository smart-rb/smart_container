# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DependencyCompatability::Registry
  class << self
    # @since 0.1.0
    include SmartCore::Container::DependencyCompatability::General

    # @param registry [SmartCore::Container::Registry]
    # @param dependency_name [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def potential_namespace_overlap?(registry, dependency_name)
      registry.any? do |(entity_name, entity)|
        next unless entity.is_a?(SmartCore::Container::Entities::Namespace)
        entity.namespace_name == dependency_name
      end
    end

    # @param registry [SmartCore::Container::Registry]
    # @param namespace_name [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def potential_dependency_overlap?(registry, namespace_name)
      registry.any? do |(entity_name, entity)|
        next unless entity.is_a?(SmartCore::Container::Entities::Dependency)
        entity.dependency_name == namespace_name
      end
    end
  end
end
