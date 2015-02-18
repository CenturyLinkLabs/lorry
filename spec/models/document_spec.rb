require 'spec_helper'

context Document do

  it { is_expected.to be_a(Document) }
  it { expect(described_class).to be_kind_of(Gistable) }
  it { expect(described_class).to respond_to(:from_gist_by_url).with(1).argument }
  it { expect(described_class).to respond_to(:from_gist_by_id).with(1).argument }
  it { expect(described_class).to respond_to(:to_gist).with(1).argument }

end
