module Lorry
  module Models
    module Gistable

      def from_gist_by_url(url)
        # get the gist id from the url - https://gist.github.com/rupakg/asdasdasdadad
        gist_id = URI.parse(url).path[1..-1].split('/')[1]
        from_gist_by_id(gist_id)
      end

      def from_gist_by_id(gist_id)
        response = github_client.gist(gist_id)
        # return the first file in the gist
        doc = response[:files].to_hash.map { |_, data| data }[0]
        doc[:id] = response[:id]
        doc[:html_url] = response[:html_url]
        doc[:description] = response[:description]
        doc[:created_at] = response[:created_at]
        doc[:updated_at] = response[:updated_at]
        doc.to_hash
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
        response = github_client.create_gist(options)
        response[:html_url]
      end

      private

      def github_client
        @github_client ||= Octokit::Client.new
      end
    end
  end
end
