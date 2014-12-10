require 'spec_helper'

require 'mv/core/constraints/containers/trigger'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Trigger do
  subject { described_class.new(:update_trigger_name, { type: :trigger, event: :update }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :trigger, event: :update) }
    its(:name) { is_expected.to eq(:update_trigger_name) }
    its(:event) { is_expected.to eq(:update) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end
end