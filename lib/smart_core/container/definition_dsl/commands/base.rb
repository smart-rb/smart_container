# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::DefinitionDSL::Commands::Base
  class << self
    # @param identifier [Boolean]
    # @return [Boolean]
    #
    # @api private
    # @since 0.19.0
    def inheritable=(identifier)
      @inheritable = identifier
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.19.0
    def inheritable?
      @inheritable
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.19.0
    def inherited(child_klass)
      child_klass.instance_variable_set(:@inheritable, true)
      super
    end
  end

  # @param regsitry [SmartCore::Container::Registry]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def call(registry); end

  # @return [Boolean]
  #
  # @api private
  # @since 0.19.0
  def inheritable?
    self.class.inheritable?
  end
end
