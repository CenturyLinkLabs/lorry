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

    context 'when enforcing the EnvFile rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'EnvFile') }
      let(:path) { [] }

      it 'adds an error when the env_file value is not a string or array' do
        subject.validate_hook({}, rule, path, errors)
        expect(errors.first.message).to eq 'value is not a string or sequence'
      end

      it 'does not add an error when the env_file value is a string' do
        subject.validate_hook('./', rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add an error when the env_file value is an array' do
        subject.validate_hook(['./'], rule, path, errors)
        expect(errors).to be_empty
      end

    end

    context 'when enforcing the DNSSearch rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'DNSSearch') }
      let(:path) { [] }

      it 'adds an error when the dns_search value is not a string or array' do
        subject.validate_hook({}, rule, path, errors)
        expect(errors.first.message).to eq 'value is not a string or sequence'
      end

      it 'does not add an error when the dns_search value is a string' do
        subject.validate_hook('www.example.com', rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add an error when the dns_search value is an array' do
        subject.validate_hook(['www.example.com'], rule, path, errors)
        expect(errors).to be_empty
      end

    end

    context 'when enforcing the Port rule' do

      let(:errors) { [] }
      let(:rule) { double('rule', name: 'Port') }
      let(:path) { [] }

      it 'adds a warning when the value(s) are not in the proper format' do
        subject.validate_hook(['not the right format'], rule, path, errors)
        expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
        expect(errors.first.message).to eq 'Invalid port format'
      end

      it 'does not add a warning when the value is in the ip:hostPort:containerPort format' do
        subject.validate_hook(['127.0.0.1:1234:1234'], rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add a warning when the value is in the hostPort:containerPort format' do
        subject.validate_hook(['1234:1234'], rule, path, errors)
        expect(errors).to be_empty
      end

      it 'does not add a warning when the value is in the containerPort format' do
        subject.validate_hook(['1234'], rule, path, errors)
        expect(errors).to be_empty
      end
    end

  end

  context 'when enforcing the Expose rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'Expose') }
    let(:path) { [] }

    it 'adds a warning when the value(s) are not in the proper format' do
      subject.validate_hook(['not the right format'], rule, path, errors)
      expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
      expect(errors.first.message).to eq 'Invalid expose format'
    end

    it 'does not add a warning when the value is in the proper format' do
      subject.validate_hook(['1234'], rule, path, errors)
      expect(errors).to be_empty
    end
  end

  context 'when enforcing the Net rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'Net') }
    let(:path) { [] }

    it 'adds a warning when the value does not start with "bridge", "none", "container:", or "host"' do
      subject.validate_hook('other', rule, path, errors)
      expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
      expect(errors.first.message).to eq 'Invalid value'
    end

    it 'does not add a warning when the value starts with "bridge", "none", "container:", or "host"' do
      subject.validate_hook('bridge: blah', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('none', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('container: blah', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('host: blah', rule, path, errors)
      expect(errors).to be_empty
    end

  end

  context 'when enforcing the DNS rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'DNS') }
    let(:path) { [] }

    it 'adds a warning when the value(s) are not in the proper format' do
      subject.validate_hook(['not the right format'], rule, path, errors)
      expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
      expect(errors.first.message).to eq 'Invalid DNS format'
    end

    it 'does not add a warning when the value is in the proper format' do
      subject.validate_hook(['8.8.8.8'], rule, path, errors)
      expect(errors).to be_empty
    end

    it 'adds an error when the value is not a string or array' do
      subject.validate_hook({}, rule, path, errors)
      expect(errors.first.message).to eq 'value is not a string or sequence'
    end

  end

  context 'when enforcing the Privileged rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'Privileged') }
    let(:path) { [] }

    it 'adds a warning when the value is not "true" or "false"' do
      subject.validate_hook('other', rule, path, errors)
      expect(errors.first.message).to eq 'Invalid value'
    end

    it 'does not add a warning when the value is "true" or "false"' do
      subject.validate_hook('true', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('false', rule, path, errors)
      expect(errors).to be_empty
    end
  end

  context 'when enforcing the Restart rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'Restart') }
    let(:path) { [] }

    it 'adds a warning when the value does not start with "no", "on-failure:", or "always"' do
      subject.validate_hook('other', rule, path, errors)
      expect(errors.first).to be_a Lorry::Errors::ComposeValidationWarning
      expect(errors.first.message).to eq 'Invalid value'
    end

    it 'does not add a warning when the value starts with "no", "on-failure:", or "always"' do
      subject.validate_hook('no', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('on-failure: meh.', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('always', rule, path, errors)
      expect(errors).to be_empty
    end
  end

  context 'when enforcing the TTY rule' do

    let(:errors) { [] }
    let(:rule) { double('rule', name: 'TTY') }
    let(:path) { [] }

    it 'adds a warning when the value is not "true" or "false"' do
      subject.validate_hook('other', rule, path, errors)
      expect(errors.first.message).to eq 'Invalid value'
    end

    it 'does not add a warning when the value is "true" or "false"' do
      subject.validate_hook('true', rule, path, errors)
      expect(errors).to be_empty

      subject.validate_hook('false', rule, path, errors)
      expect(errors).to be_empty
    end
  end

end

