module Lorry
  module Models
    class ComposeValidator < Kwalify::Validator

      attr_accessor :services
      attr_reader :schema

      def initialize
        @schema = YAML.load_file(File.expand_path('schema.yml'))
        super @schema
      end

      def validate_hook(value, rule, path, errors)
        case rule.name
        when 'Service'
          if value.include?('image') && value.include?('build')
            errors << Kwalify::ValidationError.new('service must use either image or build, not both', path)
          end
          unless value.include?('image') || value.include?('build')
            errors << Kwalify::ValidationError.new('service must include image or build', path)
          end
        when 'Image'
          value = value.to_s.strip
          if value.empty?
            errors << Lorry::Errors::ComposeValidationWarning.new("image should not be blank", path)
          end
        when 'Link'
          value = value.to_s.split(':').first
          unless services.include?(value)
            errors << Kwalify::ValidationError.new("#{value} references an undefined service", path)
          end
        when 'Environment', 'DNS', 'Search'
          unless value.is_a?(String) || value.is_a?(Array)
            errors << Kwalify::ValidationError.new('value is not a string or sequence', path)
          end
        end
      end

    end
  end
end

