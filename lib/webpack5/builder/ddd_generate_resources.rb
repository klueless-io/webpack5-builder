# frozen_string_literal: true

module Webpack5
  module Builder
    # Build generates a file for each (DDD) Domain Driven Design resource builder that needs to run
    class DddGenerateResources < BaseBuilder
      # In memory representation of the DDD run command configuration (.dddrc.json)
      attr_reader :dddrc

      def initialize(context, dddrc)
        super(context)

        @dddrc = dddrc
      end

      def generate(opts)
        # Structure Shape
        #
        # "command": "service",
        # "noun": "player",
        # "verb": "select-new-piece",
        # "description": "Each player chooses one token to represent him/her while traveling around the board.",
        # "full_command": "service:player:select-new-piece",
        # "artifact": "select-new-piece-service"

        # remove this slice[0..5] after testing
        structural.each do |structure|
          file_name = "#{structure['noun']}-#{structure['verb']}.rb"
          file_name = File.join(get_command_folder(structure['command']), file_name)
          template_file = File.join('builders', "builder_#{structure['command']}.rb")
          add_file(file_name, template_file: template_file, **opts.merge(structure))
        end
      end

      def structural
        @structural ||= dddrc['artifacts']['structural']
      end

      # This will drive of config
      def get_command_folder(command)
        case command
        when 'action'
          'actions'
        when 'query'
          'queries'
        when 'predicate'
          'predicates'
        when 'interface'
          'interfaces'
        when 'service'
          'services'
        else
          ''
        end

      end

      def debug
        puts 'domain information'
        kv 'domain'                , dddrc['domain']['name']
        kv 'source document'       , dddrc['domain']['source_document']
        # kv 'logical artifacts #'   , dddrc['artifacts']['logical'].length
        kv 'structural artifacts #', structural.length
      end
      
      private

      def kv(name, value)
        puts "#{name.rjust(30)} : #{value}"
      end
    end
  end
end
