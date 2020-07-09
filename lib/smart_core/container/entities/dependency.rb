# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::Dependency < SmartCore::Container::Entities::Base
  # @return [String]
  #
  # @api private
  # @since 0.1.0
  alias_method :dependency_name, :external_name

  # @param dependency_name [String]
  # @param dependency_definition [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(dependency_name, dependency_definition)
    super(dependency_name)
    @dependency_definition = dependency_definition
  end

  # @param host_container [SmartCore::Container, NilClass]
  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  # @version 0.8.1
  def reveal(host_container = SmartCore::Container::NO_HOST_CONTAINER)
    dependency_definition.call
  end

  private

  # @return [Proc]
  #
  # @api private
  # @since 0.1.0
  attr_reader :dependency_definition
end
