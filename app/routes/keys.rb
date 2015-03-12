module Lorry
  module Routes
    class Keys < Base

      namespace '/keys' do
        get do
          schema = Lorry::Models::ComposeValidator.schema
          @keys = schema['mapping']['=']['mapping'].keys
          status 200
          @keys.to_json
        end
      end

    end
  end
end
