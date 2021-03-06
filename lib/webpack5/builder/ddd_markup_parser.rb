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
      attr_accessor :content
      attr_reader :markup

      def initialize(**opts)
        self.content = opts[:controlled] if opts[:controlled]
      end

      # source: https://stackoverflow.com/questions/18165420/look-for-nested-xml-tag-with-regex
      #
      # see: https://rubular.com/r/wH1RnE0faGkSMn
      # see: https://rubular.com/r/23Wf7osTMKuqWQ
      #
      # V1: {(?<command>[\w]*):(?<noun>[\w]*):(?<verb>[\w-]*)[^\}]*\}(?<description>[\s\S]|[^{]*){\/[\w]*}
      # V2: {(?<command>[\w]*):(?<noun>[\w]*):(?<verb>[\w-]*)[^\}]*\}(?<description>[\s\S]|[^{]*){\/\k<command>}

      SAMPLE = <<~TEXT
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
        self.content = File.read(file)

        self
      end

      def parse
        #  Example
        #  command: "action"
        #  noun   : "banker"
        #  verb   : "revoke-admin"
        #  content: "the banker can revoke admin privilege from a player">

        @markup = content
          .to_enum(:scan, DDD_MARKUP)
          .map do
            item = OpenStruct.new(Regexp.last_match.named_captures)
            item.command = item.command.to_sym
            item.description&.strip!

            split_on_verb(item)
          end
          .flatten

        @markup.each do |item|
          set_artifact_name(item)
        end

        self
      end

      def group
        @markup = @markup
          .group_by(&:artifact)
          .map do |g|
            # g is an array with the sample [key, rows]
            rows = g[1]
            item = rows.first
            item.repeats = rows.count

            if rows.count > 1
              item.description = rows.map { |i| i.description }.join("\n\n")
            end

            item
          end

        self
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
        when :interface
          item.artifact = "i-#{item.verb}"
        when :service
          item.artifact = "#{item.verb}-service"
        else
          item.artifact = item.verb
        end
      end

      def print
        puts '-' * 100

        markup.each do |item|
          puts "#{item.repeats > 1 ? item.repeats.to_s : ' '} | #{item.command.to_s.ljust(9)} | #{item.noun.ljust(8)} | #{item.verb.ljust(25)} | #{item.artifact.ljust(30)} | #{item.description.gsub("\n","<LF>")[0..150]}"
        end

        self
      end

      def print_stats
        puts '-' * 100
        puts "   count      : #{markup.count}"
        puts "   actions    : #{markup.select { |r| r.command == :action }.count.to_s.rjust(2)}"
        puts "   queries    : #{markup.select { |r| r.command == :query }.count.to_s.rjust(2)}"
        puts "   predicates : #{markup.select { |r| r.command == :predicate }.count.to_s.rjust(2)}"
        puts "   services   : #{markup.select { |r| r.command == :service   }.count.to_s.rjust(2)}"
        puts "   models     : #{markup.group_by(&:noun).count.to_s.rjust(2)} - [#{markup.group_by(&:noun).map { |r| r[0] }.join(', ')}]"
      end
    end
  end
end
