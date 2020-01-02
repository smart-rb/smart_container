# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::Base
  # @return [String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :external_name

  # @param external_name [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(external_name)
    @external_name = external_name
  end

  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def reveal; end
end
