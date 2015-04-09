require 'spec_helper'

describe ComposeValidator do

  describe '#validate_hook' do

    context 'when enforcing the Service rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'Service') }
      let(:path) { [] }

      it 'adds an error if image and build are both present' do
        subject.validate_hook({ 'image' => 'foo', 'build' => 'foo'}, rule, path, errors)
        expect(errors.first.message).to eq ('service must use either image or build, not both')
      end

      it 'adds an error if image and build are both missing' do
        subject.validate_hook({}, rule, path, errors)
        expect(errors.first.message).to eq ('service must include image or build')
      end

      it 'does not add an error if image is present without build' do
        subject.validate_hook({ 'image' => 'foo'}, rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add an error if build is present without image' do
        subject.validate_hook({ 'build' => 'foo'}, rule, path, errors)
        expect(errors).to be_empty
      end

    end

    context 'when enforcing the Image rule' do
      let(:errors) { [] }
      let(:rule) { double('rule', name: 'Image') }
      let(:path) { [] }

      it 'adds a warning if image is blank' do
        subject.validate_hook('  ', rule, path, errors)
        expect(errors.first.message).to eq ('image should not be blank')
        expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
      end

      it 'adds a warning if image is nil' do
        subject.validate_hook(nil, rule, path, errors)
        expect(errors.first.message).to eq ('image should not be blank')
      end

      it 'does not add a warning if image is not blank' do
        subject.validate_hook('    asdf    ', rule, path, errors)
        expect(errors).to be_empty
      end

    end

    context 'when enforcing the Link rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'Link') }
      let(:path) { [] }

      before do
        subject.services = ['linky']
      end

      it 'adds an error when a linked to service is undefined' do
        subject.validate_hook('undefined_service', rule, path, errors)
        expect(errors.first.message).to eq 'undefined_service references an undefined service'
      end

      it 'adds an error when a linked to service with an alias is undefined' do
        subject.validate_hook('undefined_service:DB_1', rule, path, errors)
        expect(errors.first.message).to eq 'undefined_service references an undefined service'
      end

      it 'does not add an error when the linked to service is defined' do
        subject.validate_hook('linky', rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add an error when the linked to service is defined with an alias' do
        subject.validate_hook('linky:DB_1', rule, path, errors)
        expect(errors).to be_empty
      end

    end

    context 'when enforcing the Environment rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'Environment') }
      let(:path) { [] }

      it 'adds an error when the environment is not a string or array' do
        subject.validate_hook({}, rule, path, errors)
        expect(errors.first.message).to eq 'value is not a string or sequence'
      end

      it 'does not add an error when the environment is a string' do
        subject.validate_hook('foo=bar', rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add an error when the environment is an array' do
        subject.validate_hook(['foo=bar'], rule, path, errors)
        expect(errors).to be_empty
      end

    end

  end

end
