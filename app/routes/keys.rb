module Lorry
  module Routes
    class Keys < Base

      namespace '/keys' do
        get do
          schema = Lorry::Models::ComposeValidator.schema
          @keys = schema['mapping']['=']['mapping'].map do |validation|
            { validation[0] => validation[1].keep_if { |k, v| %w(desc required).include?(k) } }
          end
          status 200
          @keys.to_json
        end
      end

    end
  end
end
