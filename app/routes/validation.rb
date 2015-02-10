module Lorry
  module Routes
    class Validation < Base

      namespace '/validation' do
        post do
          status 201
        end
      end

    end
  end
end
