require 'spec_helper'

describe Lorry::MessageFilter do

  it('responds to #filter') do
    expect(described_class).to respond_to(:filter)
  end

  it('returns nil if the message is nil') do
    expect(described_class.filter(nil)).to be_nil
  end

  it('returns the original message if no filtering is necessary') do
    expect(described_class.filter('unfiltered message')).to eq('unfiltered message')
  end

  context('when messages should be filtered') do

    it('filters the message "key \'%s\' is undefined."') do
      expect(described_class.filter("key 'foo' is undefined.")).to eq("Invalid key: 'foo'")
    end

  end
end
