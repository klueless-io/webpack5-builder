# frozen_string_literal: true

module Webpack5
  module Builder
    # Configuration for webpack5/builder
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      puts 'resetting'
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    # Configuration class
    class Configuration
      attr_accessor :npm_package_groups

      def initialize
        @npm_package_groups = {}
      end

      def set_package_group(key, description, package_names)
        npm_package_groups[key] = PackageGroup.new(key, description, package_names)
      end

      def default_package_groups
        set_package_group('webpack', 'Webpack V5', %w[webpack webpack-cli webpack-dev-server])
        set_package_group('swc', 'SWC Transpiler', %w[@swc/cli @swc/core swc-loader])
        set_package_group('babel', 'Babel Transpiler', %w[@babel/core @babel/cli @babel/preset-env babel-loader])
        set_package_group('typescript', 'Typescript', %w[typescript ts-loader])
      end
    end

    PackageGroup = Struct.new(:key, :description, :package_names)
  end
end
