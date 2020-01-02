# frozen_string_literal: true

module SmartCore::Container::DefinitionDSL::Commands::Instantiation
  # @api private
  # @since 0.1.0
  class Compose < SmartCore::Container::DefinitionDSL::Commands::Base
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
      SmartCore::Container::RegistryBuilder.build_state(
        container_klass, registry, ignored_commands: [
          SmartCore::Container::DefinitionDSL::Commands::Instantiation::FreezeState
        ]
      )
    end

    # @return [SmartCore::Container::DefinitionDSL::Commands::Instantiation::Compose]
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
