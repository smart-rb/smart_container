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

  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def reveal
    dependency_definition.call
  end

  private

  # @return [Proc]
  #
  # @api private
  # @since 0.1.0
  attr_reader :dependency_definition
end
