require 'app/models/validation'

module Lorry
  module Routes
    class Validation < Base

      before do
        @payload = symbolize_keys(JSON.parse(request.body.read)) rescue nil
      end

      namespace '/validation' do
        options do
          status 200
        end

        post do
          @document = @payload[:document]
          @validation = Lorry::Models::Validation.new(@document)
          json(lines: document_lines, status: validation_status, errors: validation_errors)
        end
      end

      private

      def document_lines
        sio = StringIO.new(@document)
        sio.readlines
      end

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
