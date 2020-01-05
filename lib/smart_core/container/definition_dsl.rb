# frozen_string_literal: true

class SmartCore::Container
  # @api private
  # @since 0.1.0
  module DefinitionDSL
    require_relative 'definition_dsl/commands'
    require_relative 'definition_dsl/command_set'
    require_relative 'definition_dsl/inheritance'

    class << self
      # @param base_klass [Class<SmartCore::Container>]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def included(base_klass)
        base_klass.instance_variable_set(:@__container_definition_commands__, CommandSet.new)
        base_klass.instance_variable_set(:@__container_instantiation_commands__, CommandSet.new)
        base_klass.instance_variable_set(:@__container_definition_lock__, ArbitaryLock.new)
        base_klass.singleton_class.send(:attr_reader, :__container_definition_commands__)
        base_klass.singleton_class.send(:attr_reader, :__container_instantiation_commands__)
        base_klass.extend(ClassMethods)
        base_klass.singleton_class.prepend(ClassInheritance)
      end
    end

    # @api private
    # @since 0.1.0
    module ClassInheritance
      # @param child_klass [Class<SmartCore::Container>]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def inherited(child_klass)
        child_klass.instance_variable_set(:@__container_definition_commands__, CommandSet.new)
        child_klass.instance_variable_set(:@__container_instantiation_commands__, CommandSet.new)
        child_klass.instance_variable_set(:@__container_definition_lock__, ArbitaryLock.new)
        SmartCore::Container::DefinitionDSL::Inheritance.inherit(base: self, child: child_klass)
        child_klass.singleton_class.prepend(ClassInheritance)
        super
      end
    end

    # @api private
    # @since 0.1.0
    module ClassMethods
      # @param namespace_name [String, Symbol]
      # @param dependencies_definition [Block]
      # @return [void]
      #
      # @api public
      # @since 0.1.0
      def namespace(namespace_name, &dependencies_definition)
        @__container_definition_lock__.thread_safe do
          DependencyCompatability::Definition.prevent_dependency_overlap!(self, namespace_name)

          __container_definition_commands__ << Commands::Definition::Namespace.new(
            namespace_name, dependencies_definition
          )
        end
      end

      # @param dependency_name [String, Symbol]
      # @option memoize [Boolean]
      # @param dependency_definition [Block]
      # @return [void]
      #
      # @api public
      # @since 0.1.0
      # @version 0.2.0
      def register(dependency_name, memoize: true, &dependency_definition)
        @__container_definition_lock__.thread_safe do
          DependencyCompatability::Definition.prevent_namespace_overlap!(self, dependency_name)

          __container_definition_commands__ << Commands::Definition::Register.new(
            dependency_name, dependency_definition, memoize
          )
        end
      end

      # @param container_klass [Class<SmartCore::Container>]
      # @return [void]
      #
      # @api public
      # @since 0.1.0
      def compose(container_klass)
        @__container_definition_lock__.thread_safe do
          __container_definition_commands__ << Commands::Definition::Compose.new(
            container_klass
          )

          __container_instantiation_commands__ << Commands::Instantiation::Compose.new(
            container_klass
          )
        end
      end

      # @return [void]
      #
      # @api public
      # @since 0.1.0
      def freeze_state!
        @__container_definition_lock__.thread_safe do
          __container_instantiation_commands__ << Commands::Instantiation::FreezeState.new
        end
      end
    end
  end
end
