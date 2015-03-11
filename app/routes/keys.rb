module Lorry
  module Routes
    class Keys < Base

      namespace '/keys' do
        get do
          schema = YAML.load_file(File.expand_path('schema.yml'))
          @keys = schema['mapping']['=']['mapping'].keys
          status 200
          @keys.to_json
        end
      end

    end
  end
end
