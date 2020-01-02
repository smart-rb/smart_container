# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::DependencyBuilder
  class << self
    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @return [SmartCore::Container::Entities::Dependency]
    #
    # @api private
    # @since 0.1.0
    def build(dependency_name, dependency_definition)
      new(dependency_name, dependency_definition).build
    end
  end

  # @param dependency_name [String]
  # @param dependency_definition [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(dependency_name, dependency_definition)
    @dependency_name = dependency_name
    @dependency_definition = dependency_definition
  end

  # @return [SmartCore::Container::Entities::Dependency]
  #
  # @api private
  # @since 0.1.0
  def build
    SmartCore::Container::Entities::Dependency.new(dependency_name, dependency_definition)
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
end
