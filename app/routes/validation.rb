require 'app/models/validation'

module Lorry
  module Routes
    class Validation < Base

      before do
        @payload = symbolize_keys(JSON.parse(request.body.read)) rescue nil
      end

      namespace '/validation' do
        post do
          document = @payload[:document]
          @validation = Lorry::Models::Validation.new(document)
          json(status: validation_status, errors: validation_errors)
        end
      end

      private

      def validation_errors
        Array(@validation.errors).map do |e|
          { error: { message: e.message, line: e.linenum, column: e.column } }
        end
      end

      def validation_status
        @validation.errors ? 'invalid' : 'valid'
      end
    end
  end
end
