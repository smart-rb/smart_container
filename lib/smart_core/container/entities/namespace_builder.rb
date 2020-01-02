# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::NamespaceBuilder
  class << self
    # @param namespace_name [String]
    # @return [SmartCore::Container::Entities::Namespace]
    #
    # @api private
    # @since 0.1.0
    def build(namespace_name)
      new(namespace_name).build
    end
  end

  # @param namespace_name [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(namespace_name)
    @namespace_name = namespace_name
  end

  # @return [SmartCore::Container::Entities::Namespace]
  #
  # @api private
  # @since 0.1.0
  def build
    SmartCore::Container::Entities::Namespace.new(namespace_name)
  end

  private

  # @return [String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :namespace_name
end
