# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::DefinitionDSL::CommandSet
  # @since 0.1.0
  include Enumerable

  # @return [Array<SmartCore::Container::DefinitionDSL::Commands::Base>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :commands

  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize
    @commands = []
    @access_lock = SmartCore::Container::ArbitaryLock.new
  end

  # @param [SmartCore::Container::DefinitionDSL::Commands::Base]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def add_command(command)
    thread_safe { commands << command }
  end
  alias_method :<<, :add_command

  # @param block [Block]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    thread_safe { block_given? ? commands.each(&block) : commands.each }
  end

  # @param command_set [SmartCore::Container::DefinitionDSL::CommandSet]
  # @param concat_condition [Block]
  # @yield [command]
  # @yieldparam command [SmartCore::Container::DefinitionDSL::Commands::Base]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def concat(command_set, &concat_condition)
    thread_safe do
      if block_given?
        command_set.dup.each { |command| (commands << command) if yield(command) }
      else
        # :nocov:
        commands.concat(command_set.dup.commands) # NOTE: unreachable code at this moment
        # :nocov:
      end
    end
  end

  # @return [SmartCore::Container::DefinitionDSL::CommandSet]
  #
  # @api private
  # @since 0.1.0
  def dup
    thread_safe do
      self.class.new.tap do |duplicate|
        commands.each do |command|
          duplicate.add_command(command.dup)
        end
      end
    end
  end

  private

  # @param block [Block]
  # @return [Any]
  #
  # @api private
  # @since 0.1.0
  def thread_safe(&block)
    @access_lock.thread_safe(&block)
  end
end
