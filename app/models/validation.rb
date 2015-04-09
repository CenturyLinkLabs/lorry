module Lorry
  module Models
    class Validation

      def initialize(document)
        validator = ComposeValidator.new
        if yaml = YAML.load(document)
          validator.services = yaml.keys if yaml.respond_to?(:keys)
        end
        @parser = Kwalify::Yaml::Parser.new(validator)
        @parser.parse(document) if document
      rescue Kwalify::SyntaxError => e
        raise ArgumentError.new(e.message)
      end

      def errors
        @parser.errors.map { |err| err if err.instance_of? Kwalify::ValidationError }.compact
      end

      def warnings
        @parser.errors.map { |err| err if err.instance_of? Lorry::Errors::ComposeValidationWarning }.compact
      end
    end
  end
end
