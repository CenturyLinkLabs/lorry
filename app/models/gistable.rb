module Lorry
  module Models
    module Gistable

      def from_gist(url)
        # get the gist id from the url - https://gist.github.com/rupakg/asdasdasdadad
        gist_id = URI.parse(url).path[1..-1].split('/')[1]
        response = github_client.gist(gist_id)
        response[:files].to_hash.map { |_, data| data }
      end

      def to_gist(params)
        options = {}
        options[:description] = params[:description]
        options[:public]      = params[:public] || true
        if params[:file_name] && params[:file_content]
          options[:files] = {
            params[:file_name] => {
                :content => params[:file_content]
            }
          }
        end

        # create a new gist
        response = github_client.create_gist(options) if options
        response[:html_url]
      end

      private

      def github_client
        @github_client ||= Octokit::Client.new
      end
    end
  end
end
