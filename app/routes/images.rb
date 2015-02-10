module Lorry
  module Routes
    class Images < Base

      namespace '/images' do

        get do
          status 200
        end

      end

    end
  end
end
