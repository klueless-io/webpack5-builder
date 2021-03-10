# frozen_string_literal: true

module Webpack5
  # Webpack files are built here
  module Builder
    # Configuration for webpack5/builder
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    # Configuration class
    class Configuration
      attr_accessor :target_folder
      attr_accessor :template_folder
      attr_accessor :package_groups

      def initialize
        @package_groups = {}
        @target_folder = ''
        @template_folder = File.join(Dir.getwd, '.templates')
      end

      def set_package_group(key, description, package_names)
        package_groups[key] = PackageGroup.new(key, description, package_names)
      end

      def default_package_groups
        set_package_group('webpack', 'Webpack V5', %w[webpack webpack-cli webpack-dev-server])
        set_package_group('swc', 'SWC Transpiler', %w[@swc/cli @swc/core swc-loader])
        set_package_group('babel', 'Babel Transpiler', %w[@babel/core @babel/cli @babel/preset-env babel-loader])
        set_package_group('typescript', 'Typescript', %w[typescript ts-loader])
      end

      def debug
        puts '-' * 120
        puts 'webpack5 configuration'
        kv 'target_folder'    , target_folder
        kv 'template_folder'  , template_folder
        kv 'package_groups'   , package_groups
      end

      private

      def kv(name, value)
        puts "#{name.rjust(30)} : #{value.to_s}"
      end

    end

    PackageGroup = Struct.new(:key, :description, :package_names)
  end
end
