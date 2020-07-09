# frozen_string_literal: true

# @api private
# @since 0.1.0
# @version 0.8.1
module SmartCore::Container::Entities
  module NamespaceBuilder
    class << self
      # @param namespace_name [String]
      # @param host_container [SmartContainer, NilClass]
      # @return [SmartCore::Container::Entities::Namespace]
      #
      # @api private
      # @since 0.1.0
      # @version 0.8.1
      def build(namespace_name, host_container = SmartCore::Container::NO_HOST_CONTAINER)
        SmartCore::Container::Entities::Namespace.new(namespace_name, host_container)
      end
    end
  end
end
