# frozen_string_literal: true

module Webpack5
  module Builder
    # Represents a node in a JSON object
    class JsonData < OpenStruct
      def self.parse_json(json)
        json = json.to_json if json.is_a?(Hash)
        JSON.parse(json, object_class: JsonData)
      end

      def as_json
        Webpack5::Builder.data.struct_to_hash(self)
      end

      # private

      # def new_ostruct_member!(name)
      #   super(name.to_s.underscore)
      # end
    end
  end
end
