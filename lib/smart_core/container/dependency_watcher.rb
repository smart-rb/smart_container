# frozen_string_literal: true

# @api private
# @since 0.8.0
# @version 0.11.0
class SmartCore::Container::DependencyWatcher
  require_relative 'dependency_watcher/observer'

  # @param container [SmartCore::Container]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  # @version 0.11.0
  def initialize(container)
    @container = container
    @observers = Hash.new { |h, k| h[k] = [] }
    @lock = SmartCore::Engine::ReadWriteLock.new
  end

  # @param entity_path [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  # @version 0.11.0
  def notify(entity_path)
    @lock.read_sync { notify_listeners(entity_path) }
  end

  # @param entity_path [String, Symbol]
  # @param observer [Block]
  # @return [SmartCore::Container::DependencyWatcher::Observer]
  #
  # @api private
  # @since 0.8.0
  # @version 0.11.0
  def watch(entity_path, &observer) # TODO: support for pattern-based pathes
    @lock.write_sync { listen(entity_path, observer) }
  end

  # @param observer [SmartCore::Container::DependencyWatcher::Observer]
  # @return [Boolean]
  #
  # @api private
  # @since 0.8.0
  # @version 0.11.0
  def unwatch(observer)
    @lock.write_sync { remove_listener(observer) }
  end

  # @param entity_path [String, Symbol, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  # @version 0.11.0
  def clear_listeners(entity_path = nil) # TODO: support for pattern-based pathes
    @lock.write_sync { remove_listeners(entity_path) }
  end

  private

  # @return [SmartCore::Container]
  #
  # @api private
  # @since 0.8.0
  attr_reader :container

  # @return [Hash<String,SmartCore::Container::DependencyWatcher::Observer>]
  #
  # @api private
  # @since 0.8.0
  attr_reader :observers

  # @param entity_path [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  # @version 0.8.1
  def notify_listeners(entity_path)
    entity_path = indifferently_accessable_path(entity_path)
    observers.fetch(entity_path).each(&:notify!) if observers.key?(entity_path)
    container.host.notify_about_nested_changement(entity_path)
  end

  # @param entity_path [String, Symbol]
  # @param observer [Proc]
  # @return [SmartCore::Container::DependencyWatcher::Observer]
  #
  # @api private
  # @since 0.8.0
  def listen(entity_path, observer) # TODO: support for pattern-based pathes
    raise(SmartCore::Container::ArgumentError, <<~ERROR_MESSAGE) unless observer.is_a?(Proc)
      Observer is missing: you should provide an observer proc object (block).
    ERROR_MESSAGE

    entity_path = indifferently_accessable_path(entity_path)
    Observer.new(container, entity_path, observer).tap { |obs| observers[entity_path] << obs }
  end

  # @param observer [SmartCore::Container::DependencyWatcher::Observer]
  # @return [Boolean]
  #
  # @api private
  # @since 0.8.0
  def remove_listener(observer)
    unless observer.is_a?(SmartCore::Container::DependencyWatcher::Observer)
      raise(SmartCore::Container::ArgumentError, <<~ERROR_MESSAGE)
        You should provide an observer object for unsubscribion
        (an instance of SmartCore::Container::DependencyWatcher::Observer).
      ERROR_MESSAGE
    end

    unsubscribed = false
    observers.each_value do |observer_list|
      if observer_list.delete(observer)
        unsubscribed = true
        break
      end
    end
    unsubscribed
  end

  # @param entity_path [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.8.0
  def remove_listeners(entity_path) # TODO: support for pattern-based pathes
    if entity_path == nil
      observers.each_value(&:clear)
    else
      entity_path = indifferently_accessable_path(entity_path)
      observers[entity_path].clear if observers.key?(entity_path)
    end
  end

  # @param entity_path [String, Symbol]
  # @return [String]
  #
  # @api private
  # @since 0.8.0
  def indifferently_accessable_path(entity_path)
    SmartCore::Container::KeyGuard.indifferently_accessable_key(entity_path)
  end
end
