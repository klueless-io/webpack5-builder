# frozen_string_literal: true

module Webpack5
  module Builder
    # Factory helps give shape to the JSON structure.
    #
    # Helps: Because the underlying structure is a typeless and contractless
    #        OpenStruct, the developer could put any values they like in here.
    #        This factory helps to articulate the JSON contract
    class WebpackJsonFactory
      def self.build_from_json(json)
        # ToDo, build up the WebStruct by applying each JSON structure
      end

      # rubocop:disable Metrics/ParameterLists
      def self.webpack(
        settings: WebpackJsonFactory.settings,
        root_scope: WebpackJsonFactory.root_scope,
        entry: nil,
        entries: nil,
        plugins: nil,
        dev_server: nil
      )
        obj = Webpack5::Builder::JsonData.new

        obj.root_scope  = root_scope
        obj.entry       = entry unless entry.nil?
        obj.entries     = entries unless entries.nil?
        obj.dev_server  = dev_server unless dev_server.nil?
        obj.plugins     = plugins unless plugins.nil?
        obj.settings    = settings

        yield obj if block_given?

        obj
      end
      # rubocop:enable Metrics/ParameterLists

      def self.root_scope
        obj = Webpack5::Builder::JsonData.new

        obj.require_path = false
        obj.require_webpack = false
        obj.require_mini_css_extract_plugin = false
        obj.require_html_webpack_plugin = false
        obj.require_workbox_webpack_plugin = false
        obj.require_autoprefixer = false
        obj.require_precss = false

        yield obj if block_given?

        obj
      end

      def self.opinion_mode
        lambda { |json|
          json.mode = 'development'
        }
      end

      # https://webpack.js.org/configuration/mode/
      def self.mode(opinion: nil, **opts)
        obj = Webpack5::Builder::JsonData.new

        # Let the software lead/architect's opinion decide default configuration
        opinion&.call(obj)

        obj.mode = opts[:mode] unless opts[:mode].nil?

        yield obj if block_given?

        obj
      end

      def self.opinion_entry
        lambda { |json|
          json.entry = './src'
        }
      end

      # https://webpack.js.org/concepts/entry-points/
      def self.entry(opinion: nil, **opts)
        obj = Webpack5::Builder::JsonData.new

        # Let the software lead/architect's opinion decide default configuration
        opinion&.call(obj)

        # https://webpack.js.org/configuration/
        obj.entry = opts[:entry] unless opts[:entry].nil?

        yield obj if block_given?

        obj
      end

      def self.opinion_entries
        lambda { |json|
          json.home = './src/home.js'
          json.about = './src/about.js'
        }
      end

      # https://webpack.js.org/concepts/entry-points/
      def self.entries(opinion: nil)
        obj = Webpack5::Builder::JsonData.new

        # Let the software lead/architect's opinion decide default configuration
        opinion&.call(obj)

        yield obj if block_given?

        obj
      end

      def self.settings
        obj = Webpack5::Builder::JsonData.new

        # Render the TIPS

        obj.tips = false

        yield obj if block_given?

        obj
      end

      def self.opinion_dev_server
        lambda { |json|
          json.open      = true
          json.localhost = 'localhost'
        }
      end

      # https://webpack.js.org/configuration/dev-server/
      # https://github.com/webpack/webpack-dev-server
      # rubocop:disable Metrics/AbcSize
      def self.dev_server(opinion: nil, **opts)
        obj = Webpack5::Builder::JsonData.new

        # Let the software lead/architect's opinion decide default configuration
        opinion&.call(obj)

        # https://github.com/webpack/webpack-dev-server/tree/master/examples/cli/public
        obj.open      = opts[:open]            unless opts[:open].nil?         # true
        obj.localhost = opts[:localhost]       unless opts[:localhost].nil?    # localhost

        # https://github.com/webpack/webpack-dev-server/tree/master/examples/cli/watch-static
        obj.static = opts[:static]             unless opts[:static].nil? # static: ['assets', 'css']

        yield obj if block_given?

        # Samples
        # devServer: {
        #   open: true,
        #   host: 'localhost'
        # }
        #
        # devServer: {
        #   contentBase: path.join(__dirname, 'dist'),
        #   compress: true,
        #   port: 9000,
        # },

        # TIPS
        # - If you're having trouble, navigating to the /webpack-dev-server route will show where files are served. For example, http://localhost:9000/webpack-dev-server.
        # - If you want to manually recompile the bundle, navigating to the /invalidate route will invalidate the current compilation of the bundle and recompile it for you via webpack-dev-middleware.
        #   Depending on your configuration, URL may look like http://localhost:9000/invalidate.
        # - HTML template is required to serve the bundle, usually it is an index.html file. Make sure that script references are added into HTML, webpack-dev-server doesn't inject them automatically.

        obj
      end
      # rubocop:enable Metrics/AbcSize

      def self.opinion_mini_css_extract
        lambda { |json|
          json.filename = 'main.[contenthash].css'
        }
      end

      # https://webpack.js.org/plugins/mini-css-extract-plugin/
      def self.mini_css_extract(opinion: nil, **opts)
        obj = Webpack5::Builder::JsonData.new

        # Let the software lead/architect's opinion decide default configuration
        opinion&.call(obj)

        obj.filename = opts[:filename] unless opts[:filename].nil?

        yield obj if block_given?

        obj
      end
    end
  end
end
