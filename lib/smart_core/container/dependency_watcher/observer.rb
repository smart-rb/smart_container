# frozen_string_literal: true

# @api private
# @since 0.8.0
class SmartCore::Container::DependencyWatcher::Observer
  # @param container [SmartCore::Container]
  # @param dependency_path [String]
  # @param callback [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  def initialize(container, dependency_path, callback)
    @container = container
    @dependency_path = dependency_path
    @callback = callback
  end

  # @return [void]
  #
  # @api private
  # @since 0.8.0
  def notify!
    callback.call(dependency_path, container)
  end

  private

  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.8.0
  attr_reader :container

  # @return [String]
  #
  # @api private
  # @since 0.8.0
  attr_reader :dependency_path

  # @return [Proc]
  #
  # @api private
  # @since 0.8.0
  attr_reader :callback
end
