# frozen_string_literal: true

require 'json'
require 'webpack5/builder/version'
require 'webpack5/builder/base_builder'
require 'webpack5/builder/configuration'
require 'webpack5/builder/context'
require 'webpack5/builder/data_helper'
require 'webpack5/builder/package_builder'
require 'webpack5/builder/webpack_builder'
require 'webpack5/builder/webpack_json_factory'
require 'webpack5/builder/json_data'

require 'webpack5/builder/ddd_markup_parser'
require 'webpack5/builder/ddd_resource_builder'
require 'webpack5/builder/ddd_generate_resources'
require 'webpack5/builder/ddd_generate_csharp'

require 'handlebars/helpers/template'
require 'front_matter_parser'

module Webpack5
  module Builder
    # raise Webpack5::Builder::Error, 'Sample message'
    class Error < StandardError; end

    # Your code goes here...
  end
end
