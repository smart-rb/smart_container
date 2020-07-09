# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::Namespace < SmartCore::Container::Entities::Base
  # @return [String]
  #
  # @api private
  # @since 0.1.0
  alias_method :namespace_name, :external_name

  # @return [NilClass, SmartCore::Container]
  #
  # @api private
  # @since 0.8.01
  attr_reader :host_container

  # @param namespace_name [String]
  # @param host_container [NilClass, SmartCore::Container]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.8.1
  def initialize(namespace_name, host_container = SmartCore::Container::NO_HOST_CONTAINER)
    super(namespace_name)
    @container_klass = Class.new(SmartCore::Container)
    @container_instance = nil
    @host_container = host_container
    @lock = SmartCore::Container::ArbitraryLock.new
  end

  # @param runtime_host_container [SmartCore::Container, NilClass]
  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.1.0
  # @version 0.8.1
  def reveal(runtime_host_container = SmartCore::Container::NO_HOST_CONTAINER)
    thread_safe { container_instance(runtime_host_container) }
  end

  # @param dependencies_definition [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def append_definitions(dependencies_definition)
    thread_safe { container_klass.instance_eval(&dependencies_definition) }
  end

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def freeze!
    thread_safe { container_instance.freeze! }
  end

  private

  # @return [Class<SmartCore::Container>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :container_klass

  # @param runtime_host_container [SmartCore::Container, NilClass]
  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.1.0
  # @version 0.8.1
  def container_instance(runtime_host_container = SmartCore::Container::NO_HOST_CONTAINER)
    @host_container ||= runtime_host_container
    @container_instance ||= container_klass.new(
      host_container: @host_container,
      host_path: @host_container && namespace_name
    )
  end

  # @param block [Block]
  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def thread_safe(&block)
    @lock.thread_safe(&block)
  end
end
