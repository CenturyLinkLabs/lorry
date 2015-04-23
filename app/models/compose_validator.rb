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
            errors << Lorry::Errors::ComposeValidationWarning.new('image should not be blank', path)
          end
        when 'Link'
          value = value.to_s.split(':').first
          unless services.include?(value)
            errors << Kwalify::ValidationError.new("#{value} references an undefined service", path)
          end
        when 'EnvFile', 'DNSSearch'
          unless value.is_a?(String) || value.is_a?(Array)
            errors << Kwalify::ValidationError.new('value is not a string or sequence', path)
          end
        when 'Port'
          if value.is_a?(Array) && !value.empty?
            value.each { |port| validate_port_format(port, path, errors) }
          end
        when 'Expose'
          if value.is_a?(Array) && !value.empty?
            value.each { |expose| validate_expose_format(expose, path, errors) }
          end
        when 'DNS'
          if value.is_a?(String) && value.empty?
            return
          elsif value.is_a?(String)
            validate_dns_format(value, path, errors)
          elsif value.is_a?(Array)
            value.each { |dns| validate_dns_format(dns, path, errors) }
          else
            errors << Kwalify::ValidationError.new('value is not a string or sequence', path)
          end
        when 'Net'
          return if value.is_a?(String) && value.empty?
          unless value.start_with?("bridge", "none", "container:", "host")
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'Privileged', 'TTY'
          return if value.is_a?(String) && value.empty?
          unless %w(true false).include? value
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'Restart'
          return if value.is_a?(String) && value.empty?
          unless value.start_with?("no", "on-failure:", "always")
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        end
      end

      private

      def validate_port_format(value, path, errors)
        valid = false
        octet = /\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/
        port = /\d{2,6}/

        parts = value.split(':')
        case parts.size
        when 3
          valid = octet.match(parts[0]) && port.match(parts[1]) && port.match(parts[2])
        when 2
          valid = port.match(parts[0]) && port.match(parts[1])
        when 1
          valid = port.match(parts[0])
        end

        unless valid
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid port format', path)
        end
      end

      def validate_expose_format(value, path, errors)
        port = /\d{2,6}/
        unless port.match(value)
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid expose format', path)
        end
      end

      def validate_dns_format(value, path, errors)
        octet = /\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/
        unless octet.match(value)
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid DNS format', path)
        end
      end
    end
  end
end

