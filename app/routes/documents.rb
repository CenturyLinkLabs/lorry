module Lorry
  module Routes
    class Documents < Base

      namespace '/documents' do
        post do
          status 201
        end
      end

    end
  end
end
