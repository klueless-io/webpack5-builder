# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class PackageBuilder < BaseBuilder
      # In memory representation of the package.json file that is being created
      attr_writer :package

      def initialize(context)
        super(context)

        @dependency_type = :development
      end

      # -----------------------------------
      # Fluent Builder Methods
      # -----------------------------------

      def package
        return @package if defined? @package

        load
        @package
      end

      def package_file
        @package_file ||= File.join(output_path, 'package.json')
      end

      # -----------------------------------
      # Fluent Builder Methods
      # -----------------------------------

      def production
        @dependency_type = :production

        self
      end

      def development
        @dependency_type = :development

        self
      end

      # Init an NPN package
      #
      # run npm init -y
      def init
        rc 'npm init -y'
        load

        self
      end

      # Space separated list of packages
      def npm_install(packages, options: nil)
        options = parse_options(options)
        command = "npm install #{options.join(' ')} #{packages}"
        execute command
      end
      alias npm_i npm_install

      def npm_add(packages, options: nil)
        options = parse_options(options, '--package-lock-only --no-package-lock')
        command = "npm install #{options.join(' ')} #{packages}"
        execute command
      end
      alias npm_a npm_add

      # options_any?
      def npm_add_group(key, options: nil)
        group = get_group(key)

        puts "Adding #{group.description}"

        options = parse_options(options, '--package-lock-only --no-package-lock')
        # if options_any?(options, '-D', '-P')
        #   # prod_or_dev = context.dependency_type == :dev ? '-D' : '-P'
        #   # options = parse_options(options, prod_or_dev)
        # end

        rc "npm i #{options} #{group.package_names.join(' ')}"

        self
      end
      alias npm_ig npm_add_group

      # Add a group of NPN packages which get defined in configuration
      def npm_install_group(key, options: nil)
        group = get_group(key)

        puts "Installing #{group.description}"

        # if options.nil?
        #   options = context.dependency_type == :dev ? '-D' : '-P'
        # end

        rc "npm i #{options} #{group.package_names.join(' ')}"

        self
      end

      # # --no-optional
      # def npm_install_group(_key)
      #   # npm i -D webpack webpack-cli webpack-dev-server

      #   self
      # end

      # it 'has a standard error' do
      #   expect { raise Webpack5::Builder::Error, 'some message' }
      #     .to raise_error('some message')
      # end

      def load
        raise Webpack5::Builder::Error, 'package.json does not exist' unless File.exist?(package_file)

        content = File.read(package_file)
        @package = JSON.parse(content)

        self
      end

      def parse_options(options = nil, required_options = nil)
        options = [] if options.nil?
        options = options.split if options.is_a?(String)
        options.reject(&:empty?)

        required_options = [] if required_options.nil?
        required_options = required_options.split if required_options.is_a?(String)

        options | required_options
      end

      def options_any?(options, *any_options)
        (options & any_options).any?
      end

      def vscode
        puts "cd #{output_path}"
        puts package_file
        rc "code #{package_file}"
      end

      def dependency_option
        @dependency_type == :development ? '-D' : '-P'
      end

      private

      def execute(command)
        puts "RUN: #{command}"
        rc command
        load
      end

      def get_group(key)
        group = context.package_groups[key]

        raise Webpack5::Builder::Error, "unknown package group: #{key}" if group.nil?

        group
      end
    end
  end
end
