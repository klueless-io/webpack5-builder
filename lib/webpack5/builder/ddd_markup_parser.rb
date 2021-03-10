# frozen_string_literal: true

module Webpack5
  module Builder
    # Reads DDD markup that can be applied to instruction files.
    #
    # Current implementation uses REGEX to read the markup, this
    # has limitations as REGEX and deep repeating recursion is
    # painful (if not impossible).
    #
    # ToDo: Implement using a Lexer
    class DddMarkupParser
      attr_accessor :front_matter
      attr_accessor :content
      attr_reader :markup
      attr_reader :filtered_markup

      def initialize(**opts)
        self.front_matter = front_matter_defaults(opts[:front_matter]) if opts[:front_matter]
        self.content = opts[:content] if opts[:content]
      end

      # source: https://stackoverflow.com/questions/18165420/look-for-nested-xml-tag-with-regex
      #
      # see: https://rubular.com/r/wH1RnE0faGkSMn
      # see: https://rubular.com/r/23Wf7osTMKuqWQ
      #
      # V1: {(?<command>[\w]*):(?<noun>[\w]*):(?<verb>[\w-]*)[^\}]*\}(?<description>[\s\S]|[^{]*){\/[\w]*}
      # V2: {(?<command>[\w]*):(?<noun>[\w]*):(?<verb>[\w-]*)[^\}]*\}(?<description>[\s\S]|[^{]*){\/\k<command>}

      SAMPLE = <<~TEXT
                ---
                filter:
                  show_actions: true
                  show_queries: true
                  show_actions: true
                  show_predicates: true
                  show_services: true
                  domain_nouns: * # player, game, bank, property, card, square
                ---
                
                {cmd:player:get-piece}
                Each player chooses one token to represent him/her while traveling around the board.
                {/cmd}

                ### Banker

                The bank / auctioneer is controlled by the computer.

                Besides the Bank’s money, the {cmd:game:generate-title-deed}Bank holds the Title Deed cards and houses and hotels prior to purchase and use by the players.{/cmd}

                {cmd:bank:pay-salary}
                The Bank pays salaries and bonuses.
                {/cmd}

                {svc:bank:hold-an-auction}The bank sells and auctions properties{/svc} and {svc:bank:assign-title-deed}hands out their proper Title Deed cards{/svc}
      TEXT

      DDD_MARKUP = /
      {
        (?<command>[\w|-]*):
        (?<noun>[\w|-]*):
        (?<verb>[\w|-]*)
      [^\}]*\}
          (?<description>[\s\S]|[^{]*)
      {\/\k<command>}
      /x

      def load_file(file)
        parsed = FrontMatterParser::Parser.parse_file(file)

        self.front_matter = front_matter_defaults(parsed.front_matter)
        self.content = parsed.content

        self
      end

      def parse
        #  Example
        #  command: "action"
        #  noun   : "banker"
        #  verb   : "revoke-admin"
        #  content: "the banker can revoke admin privilege from a player">

        @debug = true
        @markup = content
          .to_enum(:scan, DDD_MARKUP)
          .map do
            item = OpenStruct.new(Regexp.last_match.named_captures)
            item.command = item.command.to_sym
            item.full_command = "#{item.command}:#{item.noun}:#{item.verb}"
            item.description&.strip!

            split_on_verb(item)
          end
          .flatten

        @markup.each do |item|
          set_artifact_name(item)
        end

        order

        self
      end

      def parse_to_markdown(target_file)
        output = content.gsub(DDD_MARKUP) { |_| match = Regexp.last_match; match[4] }

        File.write(target_file, output)

        self
      end

      def group
        @markup = @markup
          .group_by do |item|
            [item[:command], item[:noun], item[:verb]]
          end
          .map do |g|
            # g is an array with the sample [key, rows]
            rows = g[1]
            item = rows.first
            item.repeats = rows.count > 1 ? rows.count.to_s : ' '

            # Put 1 (or more) item.description in an array,
            # the items can have an order if applied so that they are
            # listed how you want instead of the natural order
            if rows.count == 1
              item.descriptions = [item.description]
            else
              item.descriptions = rows.map { |i| i.description }.reject(&:empty?)
            end

            item.word_wrap_descriptions = item.descriptions.flat_map{ |description| word_wrap(description, 80) }

            # Overwrite the original description with the combined ordered descriptions
            item.description = rows.map { |i| i.description }.join("\n\n")

            item
          end

        self
      end

      def word_wrap(value, width)
        value.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").split("\n")
      end

      def filter
        return self unless front_matter.use_filter

        @filtered_markup = markup.reject do |item|
          exclude_action_predicate(item) ||
          exclude_query_predicate(item) ||
          exclude_predicate_predicate(item) ||
          exclude_interface_predicate(item) ||
          exclude_service_predicate(item)
        end

        if front_matter.filter.domain_nouns != 'all'
          filter_nouns = front_matter.filter.domain_nouns.split(',').map(&:strip)
          @filtered_markup = @filtered_markup.select { |item| filter_nouns.include?(item.noun) }
        end

        if front_matter.filter.search != ''
          rex = Regexp.new(front_matter.filter.search)
          @filtered_markup = @filtered_markup.select do |item|
            item.command.match(rex) ||
            item.noun.match(rex) ||
            item.verb.match(rex) ||
            item.description.match(rex)
          end
        end

        self
      end

      def order
        return if order_by_definitions.length.zero?

        markup.sort! do |a, b|
          lhs = order_by_definitions.map do |order|
            if order.direction == :asc
              a.send(order.name)
            else
              b.send(order.name)
            end
          end

          rhs = order_by_definitions.map do |order|
            if order.direction == :asc
              b.send(order.name)
            else
              a.send(order.name)
            end
          end

          lhs <=> rhs
        end
      end

      def exclude_action_predicate(item)
        return true if item.command == :action && front_matter.filter.exclude_actions
        false
      end

      def exclude_query_predicate(item)
        return true if item.command == :query && front_matter.filter.exclude_queries
        false
      end

      def exclude_predicate_predicate(item)
        return true if item.command == :predicate && front_matter.filter.exclude_predicates
        false
      end

      def exclude_interface_predicate(item)
        return true if item.command == :interface && front_matter.filter.exclude_interfaces
        false
      end

      def exclude_service_predicate(item)
        return true if item.command == :service && front_matter.filter.exclude_services
        false
      end

      # Currently only splits on the verb, but may have reason to split on
      # Noun and command at a later place
      def split_on_verb(item)
        item.verb.split('|').map do |v|
          add_item = item.dup
          add_item.verb = v
          add_item
        end
      end

      def set_artifact_name(item)
        case item.command
        when :action
          item.artifact = "#{item.verb}-action"
        when :query
          item.artifact = "#{item.verb}-query"
        when :predicate
          item.artifact = "#{item.verb}"
        when :interface
          item.artifact = "i-#{item.verb}"
        when :service
          item.artifact = "#{item.verb}-service"
        else
          item.artifact = item.verb
        end
      end

      def print_artifacts
        return self unless front_matter.show_artifacts

        items = front_matter.use_filter ? @filtered_markup : markup

        items = paged(items)

        return self if items.count == 0

        # if configured column is not on object then remove it from list
        columns = format_artifacts_columns.select { |column| items.first.respond_to?(column.name) }

        puts '-' * 100

        items.each do |item|
          values = columns.map do |column|
            value = item.send(column.name).to_s
            value = value.strip.gsub("\n","<LF>") if column.name == :description
            rpad(value, column.width)
          end

          puts values.join(' | ')
                    # puts "#{item.repeats > 1 ? item.repeats.to_s : ' '} | #{item.command.to_s.ljust(9)} | #{item.noun.ljust(8)} | #{item.verb.ljust(30)} | #{item.artifact.ljust(35)} | #{item.description.gsub("\n","<LF>")[0..50]}"
        end

        self
      end

      def rpad(value, width)
        (value.length > width) ? value.slice(0..width) : value.ljust(width, ' ')
      end

      def print_configuration
        return self unless front_matter.show_config

        puts ''
        puts "--[ Configuration / Front Matter ]#{'-' * 66}"
        kv_config(0, "format_artifacts"  , front_matter.format_artifacts)
        kv_config(0, "show_artifacts"    , front_matter.show_artifacts)
        kv_config(0, "show_config"       , front_matter.show_config)
        kv_config(0, "show_all_stats"    , front_matter.show_all_stats)
        kv_config(0, "use_filter"        , front_matter.use_filter)
        kv_config(0, "generate_rc"       , front_matter.generate_rc)
        
        puts 'filters:'
        kv_config(2, "exclude_actions"   , front_matter.filter.exclude_actions)
        kv_config(2, "exclude_queries"   , front_matter.filter.exclude_queries)
        kv_config(2, "exclude_predicates", front_matter.filter.exclude_predicates)
        kv_config(2, "exclude_interfaces", front_matter.filter.exclude_interfaces)
        kv_config(2, "exclude_services"  , front_matter.filter.exclude_services)
        kv_config(2, "domain_nouns"      , front_matter.filter.domain_nouns)
        kv_config(2, "search"            , front_matter.filter.search)

        self
      end

      def print_filtered_stats
        return self unless front_matter.use_filter
        return self unless front_matter.show_filtered_stats

        puts "--[ Filtered Domain Statistics ]#{'-' * 84}"
        print_stats(filtered_markup)

        self
      end

      def print_all_stats
        return self unless front_matter.show_all_stats

        puts "--[ Domain Statistics ]#{'-' * 84}"
        print_stats(markup)

        self
      end

      def print_stats(items)

        puts ''
        kv_stat("count"       , count_count(items))
        kv_stat("actions"     , actions_count(items))
        kv_stat("queries"     , queries_count(items))
        kv_stat("predicates"  , predicates_count(items))
        kv_stat("interfaces"  , interfaces_count(items))
        kv_stat("services"    , services_count(items))
        nouns = domain_nouns(items)
        kv_stat("domain nouns", domain_nouns_count(items), nouns.empty? ? '' : " [#{nouns.join(', ')}]")

        self
      end

      def generate_rc(rc_file, domain_file, domain_name)
        return self unless front_matter.generate_rc

        domain = { 
          domain: { 
            name: domain_name,
            source_document: domain_file
          },
          artifacts: {
            # bounded_context
            # aggregate_root
            # model
            # value_object
            # This just an example
            logical: [
              { bounded_context: { name: domain_name } },
              { aggregate_root: { name: domain_name } },
              { model: { name: 'sample_model' } },
              { value_object: { name: 'sample_value' } },
            ],
            # command
            # noun
            # verb
            # full_command
            # description
            # descriptions
            structural: @markup.map { |m| m.to_h.except(:repeats) }
          }
        }

        File.write(rc_file, JSON.pretty_generate(domain))

        self
      end

      def count_count(items)
        items.count
      end
      def actions_count(items)
        items.select { |r| r.command == :action }.count
      end
      def queries_count(items)
        items.select { |r| r.command == :query }.count
      end
      def predicates_count(items)
        items.select { |r| r.command == :predicate }.count
      end
      def interfaces_count(items)
        items.select { |r| r.command == :interface }.count
      end
      def services_count(items)
        items.select { |r| r.command == :service   }.count
      end
      def domain_nouns_count(items)
        items.group_by(&:noun).count
      end
      def domain_nouns(items)
        items.group_by(&:noun).map { |r| r[0] }
      end

      def paged(items)
        if pagination.active
          start = (pagination.page-1) * pagination.size
          last = ((pagination.page) * pagination.size)-1

          items = items[start..last] || []
        end
        items
      end

      def kv_config(prefix_size, name, value, extra = nil)
        prefix = ' ' * prefix_size
        puts "#{prefix}#{name.ljust(20)} : #{value}#{extra}"
      end

      def kv_stat(name, count, extra = nil)
        puts " #{name.rjust(12)} : #{count.to_s.rjust(2)}#{extra}"
      end

      def handle_bool(value, default_value)
        return default_value if value.nil? || (value.is_a?(String) && value.empty?)
        return false if value.is_a?(Integer) && value != 1
        !!(value)
      end

      def front_matter_defaults(front_matter)
        front_matter = {} if front_matter.nil?
        front_matter['filter'] = {} if front_matter['filter'].nil?

        front_matter['format_artifacts'   ] = ['repeats:1', 'command:9', 'noun:8', 'verb:30', 'artifact:35', 'description:120'] if front_matter['format_artifacts'].nil?
        front_matter['show_artifacts'     ] = handle_bool(front_matter['show_artifacts'     ], true)
        front_matter['show_config'        ] = handle_bool(front_matter['show_config'        ], true)
        front_matter['show_all_stats'     ] = handle_bool(front_matter['show_all_stats'     ], true)
        front_matter['show_filtered_stats'] = handle_bool(front_matter['show_filtered_stats'], true)
        front_matter['use_filter'         ] = handle_bool(front_matter['use_filter'         ], false)
        front_matter['generate_rc'        ] = handle_bool(front_matter['generate_rc'        ], true)
        front_matter['pagination'         ] = [0, 1, 15] if front_matter['pagination'].nil?
        
        front_matter['filter']['exclude_actions'   ] = handle_bool(front_matter['filter']['exclude_actions']   , false)
        front_matter['filter']['exclude_queries'   ] = handle_bool(front_matter['filter']['exclude_queries']   , false)
        front_matter['filter']['exclude_interfaces'] = handle_bool(front_matter['filter']['exclude_interfaces'], false)
        front_matter['filter']['exclude_predicates'] = handle_bool(front_matter['filter']['exclude_predicates'], false)
        front_matter['filter']['exclude_services'  ] = handle_bool(front_matter['filter']['exclude_services'  ], false)

        front_matter['filter']['domain_nouns'      ] = 'all' if front_matter['filter']['domain_nouns'].nil?
        front_matter['filter']['search'            ] = ''    if front_matter['filter']['search'].nil?

        Webpack5::Builder.data.to_struct(front_matter)
      end

      def format_artifacts_columns
        @format_artifacts_columns ||= front_matter['format_artifacts'].map do |format|
          split = format.split(':')

          name = split[0].to_sym
          width = split[1].to_i
          OpenStruct.new(name: name, width: width)
        end
      end     

      def order_by_definitions
        return @order_by_definitions if defined? @order_by_definitions

        if front_matter['order_by'].nil?
          @order_by_definitions = []
        else
          @order_by_definitions = front_matter['order_by'].map do |format|
            split = format.split(':')

            name = split[0].to_sym
            direction = split.length > 1 ? split[1].to_sym : :asc
            OpenStruct.new(name: name, direction: direction)
          end
        end
      end

      def pagination
        return @pagination if defined? @pagination

        @pagination ||= begin
          value = front_matter['pagination']
          if value.nil?
            OpenStruct.new(active: false, page: 1, size: 50)
          else
            OpenStruct.new(active: handle_bool(value[0], false), page: value[1], size: value[2])
          end
        end
      end     
    end
  end
end
