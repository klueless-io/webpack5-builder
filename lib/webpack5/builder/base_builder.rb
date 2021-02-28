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

      def target_file(file)
        File.expand_path(File.join(output_path, file))
      end

      def template_path
        @template_path ||= File.expand_path(context.template_folder)
      end

      def template_file(file)
        File.expand_path(File.join(template_path, file))
      end

      def add_file(file, content: nil, template_file: nil)
        file = target_file(file)

        FileUtils.mkdir_p(File.dirname(file))

        content = if !content.nil?
                    content
                  elsif !template_file.nil?
                    File.read(template_file(template_file))
                  end

        File.write(file, content)

        self
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
