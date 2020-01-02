# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DependencyCompatability::General
  # @param context [Class<SmartCore::Container>, SmartCore::Container::Registry]
  # @param dependency_name [String, Symbol]
  # @return [void]
  #
  # @raise [SmartCore::Container::DependencyOverNamespaceOverlapError]
  #
  # @api private
  # @since 0.1.0
  def prevent_namespace_overlap!(context, dependency_name)
    raise(
      SmartCore::Container::DependencyOverNamespaceOverlapError,
      "Trying to overlap already registered '#{dependency_name}' namespace " \
      "with '#{dependency_name}' dependency!"
    ) if potential_namespace_overlap?(context, dependency_name)
  end

  # @param context [Class<SmartCore::Container>, SmartCore::Container::Registry]
  # @param namespace_name [String, Symbol]
  # @return [void]
  #
  # @raise [SmartCore::Container::NamespaceOverDependencyOverlapError]
  #
  # @api private
  # @since 0.1.0
  def prevent_dependency_overlap!(context, namespace_name)
    raise(
      SmartCore::Container::NamespaceOverDependencyOverlapError,
      "Trying to overlap already registered '#{namespace_name}' dependency " \
      "with '#{namespace_name}' namespace!"
    ) if potential_dependency_overlap?(context, namespace_name)
  end

  # @param context [Class<SmartCore::Container>, SmartCore::Container::Registry]
  # @param dependency_name [String, Symbol]
  # @return [Boolean]
  #
  # @api private
  # @since 0.1.0
  def potential_namespace_overlap?(context, dependency_name)
    # :nocov:
    raise NoMethodError
    # :nocov:
  end

  # @param context [Class<SmartCore::Container>, SmartCore::Container::Registry]
  # @param namespace_name [String, Symbol]
  # @return [Boolean]
  #
  # @api private
  # @since 0.1.0
  def potential_dependency_overlap?(context, namespace_name)
    # :nocov:
    raise NoMethodError
    # :nocov:
  end
end
