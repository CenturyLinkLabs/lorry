require 'spec_helper'

describe Registry do

  context 'search' do
    let(:url) { 'https://index.docker.io/v1/search?q=bar' }
    let(:uri) { URI(url) }

    before do
      allow(Net::HTTP).to receive(:get_response).with(uri)
    end

    it 'should call get response with correct uri' do
      expect(Net::HTTP).to receive(:get_response) do |uri|
        expect(uri.to_s).to eql(url)
      end
      Registry.search(q: 'bar')
    end
  end

  context 'tags' do

    context 'images with namespace and repository' do
      let(:url) { 'https://index.docker.io/v1/repositories/foo/bar/tags' }
      let(:uri) { URI(url) }

      before do
        allow(Net::HTTP).to receive(:get_response).with(uri)
      end

      it 'should call get response with correct uri' do
        expect(Net::HTTP).to receive(:get_response) do |uri|
          expect(uri.to_s).to eql(url)
        end
        Registry.list_tags('foo', 'bar')
      end
    end
    context 'images with only repository' do
      let(:url) { 'https://index.docker.io/v1/repositories/bar/tags' }
      let(:uri) { URI(url) }

      before do
        allow(Net::HTTP).to receive(:get_response).with(uri)
      end

      it 'should call get response with correct uri' do
        expect(Net::HTTP).to receive(:get_response) do |uri|
          expect(uri.to_s).to eql(url)
        end
        Registry.list_tags(nil, 'bar')
      end
    end

  end
end
