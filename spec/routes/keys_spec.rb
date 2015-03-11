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

  end

end
