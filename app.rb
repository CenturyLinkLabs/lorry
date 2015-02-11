require 'rubygems'
require 'bundler'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

# Require base
require 'sinatra/base'

require 'app/models'
require 'app/routes'

module Lorry
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
      set :protection, except: :http_origin
    end

    use Lorry::Routes::Images
    use Lorry::Routes::Validation
    use Lorry::Routes::Documents
    use Lorry::Routes::Keys
  end
end

include Lorry::Models
