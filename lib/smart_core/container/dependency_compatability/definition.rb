# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DependencyCompatability::Definition
  class << self
    # @since 0.1.0
    include SmartCore::Container::DependencyCompatability::General

    # @param container_klass [Class<SmartCore::Container>]
    # @param dependency_name [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def potential_namespace_overlap?(container_klass, dependency_name)
      anonymous_container = Class.new(container_klass).new
      anonymous_container.register(dependency_name, &(proc {}))
      false
    rescue SmartCore::Container::DependencyOverNamespaceOverlapError
      true
    end

    # @param container_klass [Class<SmartCore::Container>]
    # @param namespace_name [String, Symbol]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def potential_dependency_overlap?(container_klass, namespace_name)
      anonymous_container = Class.new(container_klass).new
      anonymous_container.namespace(namespace_name, &(proc {}))
      false
    rescue SmartCore::Container::NamespaceOverDependencyOverlapError
      true
    end
  end
end
