# frozen_string_literal: true

# @api priavate
# @since 0.1.0
module SmartCore::Container::KeyGuard
  class << self
    # @param key [Symbol, String]
    # @return [void]
    #
    # @raise [SmartCore::Container::IncompatibleEntityNameError]
    #
    # @api private
    # @since 0.1.0
    def prevent_incomparabilities!(key)
      raise(
        SmartCore::Container::IncompatibleEntityNameError,
        'Namespace/Dependency name should be a symbol or a string'
      ) unless key.is_a?(String) || key.is_a?(Symbol)
    end

    # @param key [Symbol, String]
    # @return [String]
    #
    # @api private
    # @since 0.1.0
    def indifferently_accessable_key(key)
      prevent_incomparabilities!(key)
      key.to_s
    end
  end
end
