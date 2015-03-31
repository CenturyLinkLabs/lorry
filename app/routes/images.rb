module Lorry
  module Routes
    class Images < Base

      namespace '/images' do

        get do
          # Search params: :q - search term, :n - number of results per page, :page - page number of results
          response = Lorry::Models::Registry.search(params)
          status response.code
          body response.body
        end

        get '/tags/:reponame' do
          response = Lorry::Models::Registry.list_tags(nil, params[:reponame])
          status response.code
          body response.body
        end

        get '/tags/:username/:reponame' do
          response = Lorry::Models::Registry.list_tags(params[:username], params[:reponame])
          status response.code
          body response.body
        end

      end

    end
  end
end
