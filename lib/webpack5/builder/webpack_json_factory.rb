# frozen_string_literal: true

module Webpack5
  module Builder
    # Factory helps give shape to the JSON structure.
    #
    # Helps: Because the underlying structure is a typeless and contractless
    #        OpenStruct, the developer could put any values they like in here.
    #        This factory helps to articulate the JSON contract
    class WebpackJsonFactory
      def self.webpack(
        root_scope: WebpackJsonFactory.root_scope,
        entries: []
      )
        obj = Webpack5::Builder::JsonData.new

        obj.root_scope = root_scope
        obj.entries = entries
        # sample
        # obj.name = name
        # obj.email = email unless email.nil? # dynamic inclusion

        yield obj if block_given?

        obj
      end

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

      # https://webpack.js.org/concepts/entry-points/
      def self.entry(name, path: nil)
        obj = Webpack5::Builder::JsonData.new

        obj.name = name
        obj.path = path unless path.nil?

        yield obj if block_given?

        obj
      end
    end
  end
end
