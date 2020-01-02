# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::RegistryBuilder
  # rubocop:disable Layout/LineLength
  class << self
    # @parma container [SmartCore::Container]
    # @option ignored_definition_commands [Array<Class::SmartCore::Container::DefinitionDSL::Commands::Base>>]
    # @option ignored_instantiation_commands [Array<Class::SmartCore::Container::DefinitionDSL::Commands::Base>>]
    # @return [SmartCore::Container::Registry]
    #
    # @api private
    # @since 0.1.0
    def build(container, ignored_definition_commands: [], ignored_instantiation_commands: [])
      SmartCore::Container::Registry.new.tap do |registry|
        build_definitions(container.class, registry, ignored_commands: ignored_definition_commands)
        build_state(container.class, registry, ignored_commands: ignored_instantiation_commands)
      end
    end

    # @param container_klass [Class<SmartCore::Container>]
    # @param registry [SmartCore::Container::Registry]
    # @option ignored_commands [Array<Class<SmartCore::Container::DefinitionDSL::Commands::Base>>]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def build_definitions(container_klass, registry, ignored_commands: [])
      container_klass.__container_definition_commands__.each do |command|
        next if ignored_commands.include?(command.class)
        command.call(registry)
      end
    end

    # @param container_klass [Class<SmartCore::Container>]
    # @param registry [SmartCore::Container::Registry]
    # @option ignored_commands [Array<Class<SmartCore::Container::DefinitionDSL::Commands::Base>>]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def build_state(container_klass, registry, ignored_commands: [])
      container_klass.__container_instantiation_commands__.each do |command|
        next if ignored_commands.include?(command.class)
        command.call(registry)
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
