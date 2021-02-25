# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class Context
      attr_accessor :target_folder
    end
  end
end
