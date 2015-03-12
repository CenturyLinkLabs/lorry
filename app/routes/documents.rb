require 'app/models/document'

module Lorry
  module Routes
    class Documents < Base

      namespace '/documents' do

        before do
          @payload = symbolize_keys(JSON.parse(request.body.read)) rescue nil
        end

        options do
          status 200
        end

        post do
          file = @payload[:file]
          begin
            html_url = Lorry::Models::Document.to_gist(file)
            headers 'Location' => html_url
            status 201
          rescue Octokit::UnprocessableEntity
            status 422
          end
        end

        get '/:gist_id' do
          status 200
          json Document.from_gist_by_id(params[:gist_id])
        end
      end

    end
  end
end
