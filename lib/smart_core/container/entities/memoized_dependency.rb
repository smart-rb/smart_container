# frozen_string_literal: true

module SmartCore::Container::Entities
  # @api private
  # @since 0.2.0
  class MemoizedDependency < Dependency
    # @param dependency_name [String]
    # @param dependency_definition [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def initialize(dependency_name, dependency_definition)
      super(dependency_name, dependency_definition)
      @lock = SmartCore::Container::ArbitraryLock.new
    end

    # @return [Any]
    #
    # @api private
    # @since 0.2.0
    def reveal
      @lock.thread_safe do
        unless instance_variable_defined?(:@revealed_dependency)
          @revealed_dependency = dependency_definition.call
        else
          @revealed_dependency
        end
      end
    end

    private

    # @return [Proc]
    #
    # @api private
    # @since 0.2.0
    attr_reader :dependency_definition
  end
end
