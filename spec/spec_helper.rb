require 'rack/test'

require File.expand_path '../../app.rb', __FILE__

ENV['RACK_ENV'] = 'test'
