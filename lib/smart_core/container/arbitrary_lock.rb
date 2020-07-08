# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::ArbitraryLock
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @lock = Mutex.new
  end

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def thread_safe(&block)
    @lock.owned? ? yield : @lock.synchronize(&block)
  end
end
