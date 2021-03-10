# frozen_string_literal: true

module Webpack5
  module Builder
    # Build generates a CSharp code for each (DDD) resource, this code will be deprecated
    # as it is better to generate the code fro DddGeneratedResource then from the GenerateCsharp
    class DddGenerateCsharp < BaseBuilder
      # In memory representation of the DDD run command configuration (.dddrc.json)
      attr_reader :dddrc

      def initialize(context, dddrc)
        super(context)

        @dddrc = dddrc
      end

      def generate(opts)
        # Structure Shape
        # 
        # {
        #   "settings": {
        #     "namespace": "p04_domain_monopoly_v1"
        #   },
        #   "command": "service",
        #   "noun": "player",
        #   "verb": "select-new-piece",
        #   "description": "Each player chooses one token to represent him/her while traveling around the board.",
        #   "full_command": "service:player:select-new-piece",
        #   "artifact": "select-new-piece-service"
        # }

        # remove this slice[0..5] after testing
        structural[0..990].each do |structure|
          target_folder = get_target_folder(structure)
          target_file = File.join(target_folder, get_target_file_name(structure))

          opts = {
            command_folder: get_command_folder(structure['command'])
          }
          .merge(opts)
          .merge(structure)

          template_file = File.join('structures', "#{structure['command']}.cs")
          # puts JSON.pretty_generate(opts.merge(structure))
          add_file(target_file, template_file: template_file, **opts)
        end
      end

      def get_target_folder(structure)
        opts = structure.merge(command_folder: get_command_folder(structure['command']))

        transform_content(template: "{{camel noun}}/{{camel command_folder}}", **opts)
      end

      def get_target_file_name(structure)
        # o = {
        #   name: structure['artifact'].split('-').join(' ')
        # }.merge(structure)

        # "#{structure['noun']}_#{structure['verb']}.cs"
        case structure['command']
        when 'action'
          template = '{{camel verb}}Action.cs'
        when 'query'
          template = '{{camel verb}}Query.cs'
        when 'predicate'
          template = '{{camel verb}}.cs'
        when 'interface'
          template = 'I{{camel verb}}.cs'
        when 'service'
          template = '{{camel verb}}Service.cs'
        else
          template = '{{camel name}}.cs'
        end
        transform_content(template: template, **structure)
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
