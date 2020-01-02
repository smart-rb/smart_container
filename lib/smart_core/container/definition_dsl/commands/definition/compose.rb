# frozen_string_literal: true

module SmartCore::Container::DefinitionDSL::Commands::Definition
  # @api private
  # @since 0.1.0
  class Compose < SmartCore::Container::DefinitionDSL::Commands::Base
    # @since 0.1.0
    self.inheritable = true

    # @param container_klass [Class<SmartCore::Container>]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(container_klass)
      raise(
        SmartCore::ArgumentError,
        'Container class should be a subtype of Quantum::Container'
      ) unless container_klass < SmartCore::Container

      @container_klass = container_klass
    end

    # @param registry [SmartCore::Container::Registry]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call(registry)
      SmartCore::Container::RegistryBuilder.build_definitions(container_klass, registry)
    end

    # @return [SmartCore::Container::DefinitionDSL::Commands::Definition::Compose]
    #
    # @api private
    # @since 0.1.0
    def dup
      self.class.new(container_klass)
    end

    private

    # @return [Class<SmartCore::Container>]
    #
    # @api private
    # @since 0.1.0
    attr_reader :container_klass
  end
end
