require 'app/models/document'

module Lorry
  module Routes
    class Documents < Base

      DOCUMENT_NAME = 'docker-compose.yml'

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
            gist_response = Lorry::Models::Document.to_gist(gist_options(gist_content))
            html_url = gist_response[:html_url]
            raw_url = gist_response[:files][DOCUMENT_NAME][:raw_url]
            headers 'Location' => html_url
            status 201
            { links: { gist: { href: html_url, raw_url: raw_url } } }.to_json
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
          gist_options[:description] = "#{DOCUMENT_NAME} created at Lorry.io"
          gist_options[:public] = 'false'
          gist_options[:file_name] = DOCUMENT_NAME
          gist_options[:file_content] = content
        end
      end
    end
  end
end
