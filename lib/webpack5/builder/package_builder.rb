# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class PackageBuilder < BaseBuilder
      attr_writer :package

      # def initialize(context)
      #   super(context)
      # end

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
        command = "npm install #{options} #{packages}"
        execute command
      end
      alias npmi npm_install

      def npm_add(packages, options: nil)
        options = parse_options(options, '--package-lock-only --no-package-lock')

        command = "npm install #{options} #{packages}"
        execute command
      end
      alias npma npm_add

      # Add a group of NPN packages which get defined in configuration
      def npm_install_group(key, options: nil)
        group = context.package_groups[key]

        raise Webpack5::Builder::Error, "unknown package group: #{key}" if group.nil?

        puts "Installing #{group.description}"

        if options.nil?
          options = context.current_dependency_type == :dev ? '-D' : '-P'
        end

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

        (options | required_options).join(' ')
      end

      def vscode
        puts "cd #{output_path}"
        puts package_file
        rc "code #{package_file}"
      end

      private

      def execute(command)
        puts "RUN: #{command}"
        rc command
        load
      end
    end
  end
end
