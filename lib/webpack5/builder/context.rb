# frozen_string_literal: true

require 'forwardable'

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used
    # for building package.json and webpack configuration.
    #
    # You can configure this object dynamically, such as via command line
    # but it will delegate to the configuration where applicable
    class Context
      extend Forwardable

      attr_accessor :config

      def_delegators :@config, :package_groups

      attr_accessor :target_folder

      def initialize(config)
        self.target_folder = config.target_folder
      end
    end
  end
end
