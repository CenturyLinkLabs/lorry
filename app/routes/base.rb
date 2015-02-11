require 'json'

module Lorry
  module Routes
    class Base < Sinatra::Application

      before do
        content_type :json
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
                'Access-Control-Allow-Headers' => 'Content-Type'
      end

      configure do
        set show_exceptions: false
      end

      error ArgumentError do
        [422, {'Content-Type' => 'application/json'}, { error: env['sinatra.error'].message }.to_json ]
      end

      private

      def symbolize_keys(obj)
        case obj
        when Array
          obj.map { |item| symbolize_keys(item) }
        when Hash
          obj.each_with_object({}) do |(key, value), h|
            h[key.to_sym] = symbolize_keys(value)
          end
        else
          obj
        end
      end


    end
  end
end
