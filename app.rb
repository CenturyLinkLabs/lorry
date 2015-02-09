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
    end

    use Lorry::Routes::Base
  end
end

include Lorry::Models
