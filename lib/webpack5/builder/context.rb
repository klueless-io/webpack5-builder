# frozen_string_literal: true

# require 'forwardable'

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used
    # for building package.json and webpack configuration.
    #
    # You can configure this object dynamically, it starts configuration
    # via the configuration class, but you can alter dynamically via
    # command line or builder
    class Context
      # extend Forwardable

      attr_accessor :config

      # def_delegators :@config, :package_groups

      attr_accessor :target_folder
      attr_accessor :template_folder
      attr_reader :package_groups

      def initialize(config)
        self.config = config

        @target_folder = config.target_folder
        @template_folder = config.template_folder
        @package_groups = config.package_groups.clone

        yield(self) if block_given?
      end

      def set_package_group(key, description, package_names)
        package_groups[key] = PackageGroup.new(key, description, package_names)
      end
    end
  end
end
