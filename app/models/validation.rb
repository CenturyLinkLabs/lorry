module Lorry
  module Models
    class Validation

      @@schema = Kwalify::Yaml.load_file(File.expand_path('schema.yml'))
      @@validator = Kwalify::Validator.new(@@schema)

      def initialize(document)
        @parser = Kwalify::Yaml::Parser.new(@@validator)
        @doc = document
        @parsed_doc = @parser.parse(@doc) if @doc
      rescue Kwalify::SyntaxError => e
        raise ArgumentError.new(e.message)
      end

      def errors
        @parser.errors unless Array(@parser.errors).empty?
      end
    end
  end
end
