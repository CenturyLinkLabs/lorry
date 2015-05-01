require 'spec_helper'

describe Lorry::Routes::Validation do

  describe 'OPTIONS /validation' do
    it 'returns a response with status code 200' do
      response = options '/validation'
      expect(response.status).to be 200
    end
  end

  describe 'POST validations' do

    let(:request_body) { { document: "" }.to_json }

    it 'returns a response with status code 200' do
      response = post '/validation', request_body
      expect(response.status).to eq 200
    end

    it 'returns a JSON object with an array of lines' do
      response = post '/validation', request_body
      expect(JSON.parse(response.body)['lines']).to eq []
    end

    it 'returns a JSON object with a status indicator' do
      response = post '/validation', request_body
      expect(JSON.parse(response.body)['status']).to eq 'valid'
    end

    it 'returns a JSON object with an array of errors' do
      response = post '/validation', request_body
      expect(JSON.parse(response.body)['errors']).to eq []
    end

    it 'returns a JSON object with an array of warnings' do
      response = post '/validation', request_body
      expect(JSON.parse(response.body)['warnings']).to eq []
    end

    context('when the validation returns errors') do
      let(:request_body) { { document: "foo" }.to_json }

      before do
        allow(Lorry::MessageFilter).to receive(:filter)
      end

      it 'the errors array contains an error object with message, line, and column attributes' do
        response = post '/validation', request_body
        errors = JSON.parse(response.body)['errors']
        expect(errors.first['error'].keys).to match_array(%w(message line column))
      end

      it 'the error message is filtered' do
        post '/validation', request_body
        expect(Lorry::MessageFilter).to have_received(:filter).once
      end
    end

    context('when the validation returns warnings') do
      let(:warnings) do
        [Lorry::Errors::ComposeValidationWarning.new('warning')]
      end
      let(:validation) { double('validation', warnings: warnings, errors: nil) }
      let(:request_body) { { document: "" }.to_json }

      before do
        allow(Lorry::Models::Validation).to receive(:new).and_return(validation)
        allow(Lorry::MessageFilter).to receive(:filter)
      end

      it 'the warnings array contains a warning object with message, line, and column attributes' do
        response = post '/validation', request_body
        errors = JSON.parse(response.body)['warnings']
        expect(errors.first['warning'].keys).to match_array(%w(message line column))
      end

      it 'the warning message is filtered' do
        post '/validation', request_body
        expect(Lorry::MessageFilter).to have_received(:filter).once
      end

    end
  end

end
