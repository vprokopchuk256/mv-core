require 'spec_helper'

require 'mv/core/constraints/containers/trigger'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Trigger do
  subject(:trigger) { described_class.new(:update_trigger_name, { type: :trigger, event: :update }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :trigger, event: :update) }
    its(:name) { is_expected.to eq(:update_trigger_name) }
    its(:event) { is_expected.to eq(:update) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#routed_by?" do
    subject { trigger.routed_by?(*route) }

    describe "#when correct" do
      let(:route) { ["update_trigger_name", { "type" => "trigger", "event" => "update" }] }

      it { is_expected.to be_truthy }
    end

    describe "#when incorrect" do
      let(:route) { ["update_trigger_name", { "type" => "trigger", "event" => "create" }] }

      it { is_expected.to be_falsey }
    end
  end
end