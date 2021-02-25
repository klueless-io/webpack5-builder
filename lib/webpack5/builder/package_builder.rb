# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class PackageBuilder < BaseBuilder
      # def initialize(context)
      #   super(context)
      # end

      # run npm init -y
      def init
        rc 'npm init -y'
      end
    end
  end
end
