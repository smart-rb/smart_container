# frozen_string_literal: true

class SmartCore::Container
  # @api public
  # @since 0.1.0
  Error = Class.new(SmartCore::Error)

  # @api public
  # @since 0.1.0
  ArgumentError = Class.new(SmartCore::ArgumentError)

  # @api public
  # @since 0.1.0
  IncompatibleEntityNameError = Class.new(ArgumentError)

  # @see SmartCore::Container::Registry
  #
  # @api public
  # @since 0.1.0
  FrozenRegistryError = Class.new(SmartCore::FrozenError)

  # @api public
  # @since 0.1.0
  FetchError = Class.new(Error)

  # @see SmartCore::Container::DependencyCompatability::General
  # @see SmartCore::Container::DependencyCompatability::Definition
  # @see SmartCore::Container::DependencyCompatability::Registry
  #
  # @api public
  # @since 0.1.0
  DependencyOverNamespaceOverlapError = Class.new(Error)

  # @see SmartCore::Container::DependencyCompatability::General
  # @see SmartCore::Container::DependencyCompatability::Definition
  # @see SmartCore::Container::DependencyCompatability::Registry
  #
  # @api public
  # @since 0.1.0
  NamespaceOverDependencyOverlapError = Class.new(Error)

  # @see SmartCore::Container::DependencyResolver
  # @see SmartCore::Container::Registry
  #
  # @api public
  # @since 0.1.0
  class ResolvingError < FetchError
    # @return [String]
    #
    # @api private
    # @since 0.1.0
    attr_reader :path_part

    # @param message [String]
    # @param path_part [String]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(message = nil, path_part:)
      @path_part = path_part
      super(message)
    end
  end
end
