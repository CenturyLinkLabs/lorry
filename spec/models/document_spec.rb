require 'spec_helper'

context Document do

  it { be_a(Document) }
  it { be_kind_of(Gistable) }
  it { respond_to(:from_gist_by_url).with(1).argument }
  it { respond_to(:from_gist_by_id).with(1).argument }
  it { respond_to(:to_gist).with(1).argument }

end
