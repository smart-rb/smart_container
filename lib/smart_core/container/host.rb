# frozen_string_literal: true

# @api private
# @since 0.8.1
class SmartCore::Container::Host
  class << self
    # @param container [SmartCore::Container]
    # @param path [String]
    # @return [SmartCore::Container::Host]
    #
    # @api private
    # @since 0.8.1
    def build(container, path) # rubocop:disable Metrics/AbcSize
      if (container.nil? && !path.nil?) || (!container.nil? && path.nil?)
        raise(SmartCore::Container::ArgumentError, <<~ERROR_MESSAGE)
          Host container requires both host container instance and host container path
          (container: #{container.inspect} / path: #{path.inspect})
        ERROR_MESSAGE
      end

      if (!container.nil? && !path.nil?) &&
         (!container.is_a?(SmartCore::Container) || !path.is_a?(String))
        raise(SmartCore::Container::ArgumentError, <<~ERROR_MESSAGE)
          Host container should be a type of SmartCore::Container
          and host path should be a type of String.
        ERROR_MESSAGE
      end

      new(container, path)
    end
  end

  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.8.1
  attr_reader :container

  # @return [String]
  #
  # @api private
  # @since 0.8.1
  attr_reader :path

  # @return [Boolean]
  #
  # @api private
  # @since 0.8.1
  attr_reader :exists
  alias_method :exists?, :exists
  alias_method :present?, :exists

  # @param container [SmartCore::Container]
  # @param path [String]
  # @return [void]
  #
  # @api private
  # @since 0.8.1
  def initialize(container, path)
    @container = container
    @path = path
    @exists = !!container
  end

  # @param nested_entity_path [String]
  # @return [void]
  #
  # @api private
  # @since 0.8.1
  def notify_about_nested_changement(nested_entity_path)
    return unless exists?
    host_path = "#{path}" \
                "#{SmartCore::Container::DependencyResolver::PATH_PART_SEPARATOR}" \
                "#{nested_entity_path}"
    container.watcher.notify(host_path)
  end
end
