# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::DependencyBuilder
  class << self
    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @param memoize [Boolean]
    # @return [SmartCore::Container::Entities::Dependency]
    #
    # @api private
    # @since 0.1.0
    # @version 0.2.0
    def build(dependency_name, dependency_definition, memoize)
      new(dependency_name, dependency_definition, memoize).build
    end
  end

  # @param dependency_name [String]
  # @param dependency_definition [Proc]
  # @param memoize [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.2.0
  def initialize(dependency_name, dependency_definition, memoize)
    @dependency_name = dependency_name
    @dependency_definition = dependency_definition
    @memoize = memoize
  end

  # @return [SmartCore::Container::Entities::Dependency]
  #
  # @api private
  # @since 0.1.0
  # @version 0.2.0
  def build
    memoize ? build_memoized_dependency : build_original_dependency
  end

  private

  # @return [String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :dependency_name

  # @return [Proc]
  #
  # @api private
  # @since 0.1.0
  attr_reader :dependency_definition

  # @return [Boolean]
  #
  # @api private
  # @since 0.2.0
  attr_reader :memoize

  # @return [SmartCore::Container::Entities::Dependency]
  #
  # @api private
  # @since 0.2.0
  def build_memoized_dependency
    SmartCore::Container::Entities::MemoizedDependency.new(dependency_name, dependency_definition)
  end

  # @return [SmartCore::Container::Entities::Dependency]
  #
  # @api private
  # @since 0.2.0
  def build_original_dependency
    SmartCore::Container::Entities::Dependency.new(dependency_name, dependency_definition)
  end
end
