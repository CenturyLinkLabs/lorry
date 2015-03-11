module Lorry
  module Models
    class Validation

      def initialize(document)
        validator = ComposeValidator.new
        validator.services = YAML.load(document).keys
        @parser = Kwalify::Yaml::Parser.new(validator)
        @parser.parse(document) if document
      rescue Kwalify::SyntaxError => e
        raise ArgumentError.new(e.message)
      end

      def errors
        @parser.errors unless Array(@parser.errors).empty?
      end
    end
  end
end
