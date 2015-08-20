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
          validate_service_name(value, path, errors)
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
        when 'EnvFile', 'DNSSearch', 'DNS', 'Command'
          unless value.is_a?(String) || value.is_a?(Array)
            errors << Kwalify::ValidationError.new('value is not a string or sequence', path)
          end
        when 'Port'
          unless value.is_a?(String) && value.empty?
            validate_port_format(value, path, errors)
          end
        when 'Expose'
          unless value.is_a?(String) && value.empty?
            validate_expose_format(value, path, errors)
          end
        when 'Net'
          return if value.is_a?(String) && value.empty?
          unless value.start_with?("bridge", "none", "container:", "host")
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'MACAddress'
          unless value.is_a?(String) && value.empty?
            validate_mac_address_format(value, path, errors)
          end
        when 'Privileged', 'TTY', 'ReadOnly'
          return if value.is_a?(String) && value.empty?
          unless %w(true false).include? value
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'Restart'
          return if value.is_a?(String) && value.empty?
          unless value.start_with?("no", "on-failure:", "always")
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'CPUShares'
          begin
            Integer(value)
          rescue ArgumentError
            errors << Lorry::Errors::ComposeValidationWarning.new('Invalid value', path)
          end
        when 'Environment'
          unless value.is_a?(Array) || value.is_a?(Hash)
            errors << Kwalify::ValidationError.new('value is not a mapping or a sequence', path)
          end
        when 'CPUSet'
          unless value.is_a?(String) && value.empty?
            validate_cpuset_format(value, path, errors)
          end
        end
      end

      private

      def validate_port_format(value, path, errors)
        valid = false
        octet = /^\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}$/
        port = /^\d{2,6}$/

        parts = value.to_s.split(':')
        case parts.size
        when 3
          valid = octet.match(parts[0]) && port.match(parts[1]) && port.match(parts[2]) && value.to_s.count(':') == 2
        when 2
          valid = port.match(parts[0]) && port.match(parts[1]) && value.to_s.count(':') == 1
        when 1
          valid = port.match(parts[0]) && value.to_s.count(':') == 0
        end

        unless valid
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid port format', path)
        end
      end

      def validate_expose_format(value, path, errors)
        port = /^\d{2,6}$/
        unless port.match(value.to_s)
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid expose format', path)
        end
      end

      def validate_service_name(value, path, errors)
        regex = /^[a-zA-Z0-9]+(?:[._-][a-zA-Z0-9]+)*$/
        regex_with_build = /^[a-z0-9]+(?:[._-][a-z0-9]+)*$/
        service_name = path[0]
        if value.include?('build')
          unless service_name =~ regex_with_build
            errors << Kwalify::ValidationError.new('Invalid service name. Valid characters are [a-z0-9._-] but not starting or ending with [.-_]', path)
          end
        else
          unless service_name =~ regex
            errors << Kwalify::ValidationError.new('Invalid service name. Valid characters are [a-zA-Z0-9._-] but not starting or ending with [.-_]', path)
          end
        end
      end

      def validate_mac_address_format(value, path, errors)
        regex = /^(?:[0-9A-Fa-f]{2}([-:]))(?:[0-9A-Fa-f]{2}\1){4}[0-9A-Fa-f]{2}$/
        unless value =~ regex
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid MAC address format', path)
        end
      end

      def validate_cpuset_format(value, path, errors)
        regex = /^\d{1,2}[-,]\d{1,2}$/
        unless value =~ regex
          errors << Lorry::Errors::ComposeValidationWarning.new('Invalid CPU set format. Valid values are 0,1 or 0-3', path)
        end
      end

    end
  end
end

