require 'spec_helper'

describe Gistable do

  subject do
    Class.new do
      include Gistable

    end.new
  end

  let(:fake_gh_client) { Octokit::Client.new }
  let(:gist_response) do
    {
      id: '1111',
      html_url: 'https://gist.github.com/1111',
      description: 'description',
      created_at: '2014-08-27 16:09:45 UTC',
      updated_at: '2014-08-27 16:09:45 UTC',
      files: {
        "test.md" => {
          filename: 'test.md',
          type: 'text/plain',
          language: 'Markdown',
          raw_url: "https://gist.githubusercontent.com/username/1111/raw/22222222/test.md",
          size: 10,
          truncated: false,
          content: 'this is a sample file'
        }
      }
    }
  end

  before do
    allow(subject).to receive(:github_client).and_return(fake_gh_client)
  end

  context 'retrieve gist by id' do
    before do
      allow(fake_gh_client).to receive(:gist).with('1111').and_return(gist_response)
    end

    it 'should return the valid document' do
      document = subject.from_gist_by_id('1111')
      expect(document[:id]).to eql('1111')
    end
  end

  describe 'retrieve gist by url' do
    before do
      allow(fake_gh_client).to receive(:gist).with('1111').and_return(gist_response)
    end

    it 'should return the valid document' do
      document = subject.from_gist_by_url('https://gist.github.com/username/1111')
      expect(document[:id]).to eql('1111')
    end

  end

  describe 'save gist' do
    let(:options) do
      {
          description: 'compose.yml created at Lorry.io',
          public: 'false',
          files: {
             'compose.yml' => {
              content: 'this is a sample file'
            }
          }
      }
    end
    let(:gist_content) { 'this is a sample file' }

    before do
      allow(fake_gh_client).to receive(:create_gist).with(options).and_return({html_url: 'https://gist.github.com/2222'})
    end

    it 'should create a new gist and return the url' do
      resp = subject.to_gist(gist_content)
      expect(resp).to eql('https://gist.github.com/2222')
    end

  end


end
