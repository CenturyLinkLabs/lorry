require 'spec_helper'

describe Lorry::Routes::Keys do

  describe 'GET keys' do

    it 'returns a response with status code 200' do
      response = get '/keys'
      expect(response.status).to eq 200
    end

    it 'returns an array' do
      response = get '/keys'
      expect(JSON.parse(response.body)).to be_an Array
      expect(JSON.parse(response.body)).not_to be_empty
    end

    it 'returns an array of hashes' do
      response = get '/keys'
      expect(JSON.parse(response.body)).to all(be_a Hash)
    end

    it 'returns an array of hashes, each having a description' do
      response = get '/keys'
      expect(JSON.parse(response.body)).to all( satisfy { |h| h.each_value { |v| v.has_key?('desc') } })
    end

    it 'returns an array of hashes, each indicating whether or not it is required' do
      response = get '/keys'
      expect(JSON.parse(response.body)).to all( satisfy { |h| h.each_value { |v| v.has_key?('required') } })
    end
  end

end
