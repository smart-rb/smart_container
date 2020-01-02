# frozen_string_literal: true

# @api private
# @since 0.1.0
module SmartCore::Container::DefinitionDSL::Inheritance
  class << self
    # @option base [Class<SmartCore::Container>]
    # @option child [Class<SmartCore::Container>]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def inherit(base:, child:)
      child.__container_definition_commands__.concat(
        base.__container_definition_commands__, &:inheritable?
      )

      child.__container_instantiation_commands__.concat(
        base.__container_instantiation_commands__, &:inheritable?
      )
    end
  end
end
