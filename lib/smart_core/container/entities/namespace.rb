# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::Entities::Namespace < SmartCore::Container::Entities::Base
  # @return [String]
  #
  # @api private
  # @since 0.1.0
  alias_method :namespace_name, :external_name

  # @param namespace_name [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(namespace_name)
    super(namespace_name)
    @container_klass = Class.new(SmartCore::Container)
    @container_instance = nil
    @lock = SmartCore::Container::ArbitraryLock.new
  end

  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.1.0
  def reveal
    thread_safe { container_instance }
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

  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.1.0
  def container_instance
    @container_instance ||= container_klass.new
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
