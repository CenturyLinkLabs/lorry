module Lorry
  module Routes
    class Keys < Base

      namespace '/keys' do
        get do
          status 200
        end
      end

    end
  end
end
