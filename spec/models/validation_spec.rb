require 'spec_helper'

describe Validation do
  let(:parser_with_errors) do
    double('parser',
           parse: true,
           errors: [Kwalify::ValidationError.new('error'),
                    Lorry::Errors::ComposeValidationWarning.new('warning')])
  end
  let(:parser_without_errors) { double('parser', errors: [], warnings: []) }
  let(:validator) { double('validator') }

  before do
    allow(ComposeValidator).to receive(:new).and_return(validator)
    allow(validator).to receive(:services=).and_return(true)
    allow(YAML).to receive(:load).and_return(double(keys:[]))
  end

  describe '#errors' do
    context('when the document has errors') do
      before do
        allow(Kwalify::Yaml::Parser).to receive(:new).and_return(parser_with_errors)
      end

      subject { Lorry::Models::Validation.new(nil) }

      it('returns an array') do
        expect(subject.errors).to be_an(Array)
      end

      it('returns an array with only Kwalify::ValidationError instances') do
        expect(subject.errors).to all(be_an_instance_of Kwalify::ValidationError)
      end
    end
  end

  describe '#warnings' do
    context('when the document has warnings') do
      before do
        allow(Kwalify::Yaml::Parser).to receive(:new).and_return(parser_with_errors)
      end

      subject { Lorry::Models::Validation.new(nil) }

      it('returns an array') do
        expect(subject.warnings).to be_an(Array)
      end

      it('returns an array with only Lorry::Errors::ComposeValidationWarning instances') do
        expect(subject.warnings).to all(be_an_instance_of Lorry::Errors::ComposeValidationWarning)
      end
    end
  end
end
