# frozen_string_literal: true

module Webpack5
  module Builder
    # Context is a data object holding onto state that is used when building webpack configuration.
    class BaseBuilder
      attr_accessor :context

      def initialize(context)
        self.context = context
      end

      def output_path
        @output_path ||= File.expand_path(context.target_folder)
      end

      def run_command(command)
        # Deep path create if needed
        FileUtils.mkdir_p(output_path)

        build_command = "cd #{output_path} && #{command}"

        system(build_command)
      end
      alias rc run_command
    end
  end
end
