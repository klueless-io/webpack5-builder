# frozen_string_literal: true

module Webpack5
  module Builder
    # Build (DDD) Domain Driven Design resource builders
    class DddResourceBuilder < BaseBuilder
      # In memory representation of the DDD run command configuration (.dddrc.json)
      attr_reader :dddrc

      def initialize(context, dddrc)
        super(context)

        @dddrc = dddrc
      end

      # -----------------------------------
      # Builder Attributes
      # -----------------------------------
    end
  end
end
