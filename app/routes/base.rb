module Lorry
  module Routes
    class Base < Sinatra::Application

      before do
        headers 'Content-Type' => 'application/json'
      end

      get "/images" do
        status 200
      end

      get "/keys" do
        status 200
      end

      post "/validation" do
        status 201
      end

      post "/document" do
        status 201
      end
    end
  end
end
