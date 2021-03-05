# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class WebpackBuilder < BaseBuilder
      # In memory representation of .webpack-rc.json and generator for webpack.config.js
      # attr_writer :webpack_config
      attr_writer :webpack_rc

      def initialize(context)
        super(context)

        @factory = Webpack5::Builder::WebpackJsonFactory
      end

      # -----------------------------------
      # Builder Attributes
      # -----------------------------------

      # def webpack_config
      #   return @webpack_config if defined? @webpack_config

      #   load

      #   @webpack_config
      # end

      # def webpack_config_file
      #   # Output Path may not be enough, I may need a webpack output path
      #   @webpack_config_file ||= File.join(output_path, 'webpack.config.js')
      # end

      def webpack_rc
        return @webpack_rc if defined? @webpack_rc

        load_webpack_rc

        @webpack_rc
      end

      def webpack_rc_file
        @webpack_rc_file ||= File.join(output_path, '.webpack-rc.json')
      end

      # -----------------------------------
      # Fluent Builder Methods
      # -----------------------------------

      # Webpack init will create (and load) .webconfig-rc.json
      #
      # @param [bool] reinitialize Do you want to clear out any existing configuration, defaults to false
      def webpack_init(reinitialize: false)
        File.delete(webpack_rc_file) if reinitialize && File.exist?(webpack_rc_file)

        if File.exist?(webpack_rc_file)
          load_webpack_rc
        else
          @webpack_rc = @factory.webpack
          write_webpack_rc
        end

        self
      end

      def webpack_dev_server(**dev_server_opts, &block)
        if @webpack_rc.dev_server.nil?
          if block
            dev_server = @factory.dev_server(&block)
          else
            dev_server_opts = { opinion: @factory.opinion_dev_server } if dev_server_opts.empty?
            dev_server = @factory.dev_server(**dev_server_opts)
          end
          @webpack_rc.dev_server = dev_server
        end
        write_webpack_rc

        self
      end

      # # Set a property value in the webpack_config
      # def set(key, value)
      #   load

      #   @webpack_config[key] = value

      #   write

      #   self
      # end

      # -----------------------------------
      # Helpers
      # -----------------------------------

      # Debug method to open the webpack_config file in vscode
      # ToDo: Maybe remove
      def vscode
        puts "cd #{output_path}"
        puts webpack_rc_file
        rc "code #{webpack_rc_file}"

        self
      end

      def pause(seconds = 1)
        sleep(seconds)

        self
      end

      private

      # Load the existing .webpack-rc.json into memory
      def load_webpack_rc
        raise Webpack5::Builder::Error, '.webpack-rc.json does not exist' unless File.exist?(webpack_rc_file)

        content = File.read(webpack_rc_file)
        @webpack_rc = JSON.parse(content, object_class: Webpack5::Builder::JsonData)

        self
      end

      def write_webpack_rc
        content = JSON.pretty_generate(@webpack_rc.as_json)

        FileUtils.mkdir_p(File.dirname(webpack_rc_file))

        File.write(webpack_rc_file, content)

        self
      end
    end
  end
end
