require 'spec_helper'

describe Lorry::Routes::Images do

  describe 'GET /images' do

    context 'when images with search term are found' do

      let(:response) do
        double(:response,
           body: "{\"results\": [{\"name\": \"foo/bar\"}, {\"name\": \"fooz/baaz\"}],\"query\": \"bar\"}",
           code: 200
        )
      end

      before do
        allow(Registry).to receive(:search).and_return(response)
      end

      it 'calls the Registry search api with correct params' do
        expect(Registry).to receive(:search).with({'q' => 'bar', 'n' => '1', 'page' => '2'}).exactly(:once)
        get '/images?q=bar&n=1&page=2'
      end

      it 'returns a success status code' do
        get '/images?q=bar'
        expect(last_response.status).to eql(200)
      end

      it 'returns the matching images' do
        get '/images?q=bar'
        expect(JSON.parse(last_response.body)["results"].count).to eql(2)
      end
    end

    context 'when images with search term are not found' do
      let(:response) do
        double(:response,
           body: "{\"results\": [],\"query\": \"invalid\"}",
           code: 404
        )
      end

      before do
        allow(Registry).to receive(:search).and_return(response)
      end

      it 'calls the Registry search api with correct params' do
        expect(Registry).to receive(:search).with({'q' => 'invalid'}).exactly(:once)
        get '/images?q=invalid'
      end

      it 'returns a not found status code' do
        get '/images?q=invalid'
        expect(last_response.status).to eql(404)
      end

      it 'returns no images' do
        get '/images?q=invalid'
        expect(JSON.parse(last_response.body)["results"].count).to eql(0)
      end

    end

  end

  describe 'GET /images/tags' do

    context 'when tags are found' do
      let(:response) do
        double(:response,
           body: "[{\"layer\": \"d9756459\", \"name\": \"latest\"}, {\"layer\": \"c97dc5cd\", \"name\": \"0.1.1\"}]",
           code: 200
        )
      end
      before do
        allow(Registry).to receive(:list_tags).and_return(response)
      end

      context 'when image has namespace and repository' do
        it 'calls the Registry tags api with correct params' do
          expect(Registry).to receive(:list_tags).with('foo', 'bar').exactly(:once)
          get '/images/tags/foo/bar'
        end

        it 'returns a success status code' do
          get '/images/tags/foo/bar'
          expect(last_response.status).to eql(200)
        end

        it 'returns the matching images' do
          get '/images/tags/foo/bar'
          expect(JSON.parse(last_response.body).count).to eql(2)
        end
      end

      context 'when image has only repository' do
        it 'calls the Registry tags api with correct params' do
          expect(Registry).to receive(:list_tags).with(nil, 'bar').exactly(:once)
          get '/images/tags/bar'
        end

        it 'returns a success status code' do
          get '/images/tags/bar'
          expect(last_response.status).to eql(200)
        end

        it 'returns the matching images' do
          get '/images/tags/bar'
          expect(JSON.parse(last_response.body).count).to eql(2)
        end
      end
    end

    context 'when tags are not found' do
      let(:response) do
        double(:response,
           body: "error html",
           code: 404
        )
      end
      before do
        allow(Registry).to receive(:list_tags).and_return(response)
      end

      it 'calls the Registry tags api with correct params' do
        expect(Registry).to receive(:list_tags).with('foo', 'bar').exactly(:once)
        get '/images/tags/foo/bar'
      end

      it 'returns a not found status code' do
        get '/images/tags/invalid/invalid'
        expect(last_response.status).to eql(404)
      end

      it 'returns error html in response body' do
        get '/images/tags/invalid/invalid'
        expect(last_response.body).to eql("error html")
      end

    end

  end

end
