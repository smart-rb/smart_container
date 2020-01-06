# frozen_string_literal: true

# @api private
# @since 0.1.0
# @version 0.4.0
class SmartCore::Container::DependencyResolver::Route
  require_relative 'route/cursor'

  # @since 0.1.0
  include Enumerable

  class << self
    # @param path [String, Symbol]
    # @return [SmartCore::Container::DependencyResolver::Route]
    #
    # @api private
    # @since 0.1.0
    def build(path)
      new(SmartCore::Container::KeyGuard.indifferently_accessable_key(path))
    end

    # @return [Array<String>]
    #
    # @api private
    # @since 0.1.0
    # @version 0.4.0
    def build_path(*path_parts)
      path_parts.join(SmartCore::Container::DependencyResolver::PATH_PART_SEPARATOR)
    end
  end

  # @return [Integer]
  #
  # @api private
  # @since 0.1.0
  attr_reader :size

  # @return [String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :path

  # @param path [String]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.4.0
  def initialize(path)
    @path = path
    @path_parts = path.split(SmartCore::Container::DependencyResolver::PATH_PART_SEPARATOR).freeze
    @size = @path_parts.size
  end

  # @param block [Block]
  # @yield cursor [SmartCore::Container::DependencyResolver::Route::Cursor]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    enumerator = Enumerator.new do |yielder|
      path_parts.each_with_index do |path_part, path_part_index|
        cursor = Cursor.new(path_part, path_part_index, self)
        yielder.yield(cursor)
      end
    end

    block_given? ? enumerator.each(&block) : enumerator
  end

  private

  # @return [Array<String>]
  #
  # @api private
  # @since 0.1.0
  attr_reader :path_parts
end
