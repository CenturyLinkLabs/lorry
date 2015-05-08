require 'app/message_filter'
require 'app/models/validation'

module Lorry
  module Routes
    class Validation < Base

      namespace '/validation' do

        before do
          @payload = symbolize_keys(JSON.parse(request.body.read)) rescue nil
        end

        options do
          status 200
        end

        post do
          @document = @payload[:document] + ' '
          @validation = Lorry::Models::Validation.new(@document)
          json(
            lines: document_lines,
            status: validation_status,
            errors: validation_errors,
            warnings: validation_warnings
          )
        end
      end

      private

      def document_lines
        sio = StringIO.new(@document)
        sio.readlines
      end

      def validation_errors
        Array(@validation.errors).map do |e|
          { error: { message: filter_message(e.message), line: e.linenum, column: e.column } }
        end
      end

      def validation_warnings
        Array(@validation.warnings).map do |w|
          { warning: { message: filter_message(w.message), line: w.linenum, column: w.column } }
        end
      end

      def validation_status
        Array(@validation.errors).empty? ? 'valid' : 'invalid'
      end

      def filter_message(message)
        Lorry::MessageFilter.filter(message)
      end
    end
  end
end
