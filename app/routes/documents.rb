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
          gist_content = @payload[:document]
          begin
            html_url = Lorry::Models::Document.to_gist(gist_options(gist_content))
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

      private

      def gist_options(content)
        {}.tap do |gist_options|
          gist_options[:description] = 'compose.yml created at Lorry.io'
          gist_options[:public] = 'false'
          gist_options[:file_name] = 'compose.yml'
          gist_options[:file_content] = content
        end
      end
    end
  end
end
