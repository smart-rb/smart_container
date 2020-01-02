# frozen_string_literal: true

# @api private
# @since 0.1.0
class SmartCore::Container::DependencyResolver::Route::Cursor
  # @return [String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :path_part
  alias_method :current_path, :path_part

  # @param path_part [String]
  # @param path_part_index [Integer]
  # @param route [SmartCore::Container::DependencyResolver::Route]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(path_part, path_part_index, route)
    @path_part = path_part
    @path_part_index = path_part_index
    @route = route
  end

  # @return [Boolean]
  #
  # @api private
  # @since 0.1.0
  def last?
    route.size <= (path_part_index + 1)
  end

  private

  # @return [Integer]
  #
  # @api private
  # @since 0.1.0
  attr_reader :path_part_index

  # @return [SmartCore::Container::DependencyResolver::Route]
  #
  # @api private
  # @since 0.1.0
  attr_reader :route
end
