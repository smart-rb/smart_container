# frozen_string_literal: true

module SmartCore::Container::DefinitionDSL::Commands::Definition
  # @api private
  # @since 0.1.0
  class Register < SmartCore::Container::DefinitionDSL::Commands::Base
    # @since 0.1.0
    self.inheritable = true

    # @return [String]
    #
    # @api private
    # @since 0.1.0
    attr_reader :dependency_name

    # @param dependency_name [String, Symbol]
    # @param dependency_definition [Proc]
    # @param memoize [Boolean]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    # @version 0.2.0
    def initialize(dependency_name, dependency_definition, memoize)
      SmartCore::Container::KeyGuard.indifferently_accessable_key(dependency_name).tap do |name|
        @dependency_name = name
        @dependency_definition = dependency_definition
        @memoize = memoize
      end
    end

    # @param registry [SmartCore::Container::Registry]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    # @version 0.2.0
    def call(registry)
      registry.register_dependency(dependency_name, memoize: memoize, &dependency_definition)
    end

    # @return [SmartCore::Container::DefinitionDSL::Commands::Definition::Register]
    #
    # @api private
    # @since 0.1.0
    # @version 0.2.0
    def dup
      self.class.new(dependency_name, dependency_definition, memoize)
    end

    private

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
  end
end
