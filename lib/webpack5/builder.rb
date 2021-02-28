# frozen_string_literal: true

require 'json'
require 'webpack5/builder/version'
require 'webpack5/builder/base_builder'
require 'webpack5/builder/configuration'
require 'webpack5/builder/context'
require 'webpack5/builder/package_builder'

require 'handlebars/helpers/template'

module Webpack5
  module Builder
    # raise Webpack5::Builder::Error, 'Sample message'
    class Error < StandardError; end

    # Your code goes here...
  end
end
