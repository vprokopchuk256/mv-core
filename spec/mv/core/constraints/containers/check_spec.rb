require 'spec_helper'

require 'mv/core/constraints/containers/check'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Check do
  subject(:check) { described_class.new(:chk_mv_table_name, { type: :check }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :check) }
    its(:name) { is_expected.to eq(:chk_mv_table_name) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#routed_by?" do
    subject { check.routed_by?(*route) }

    describe "#when correct" do
      let(:route) { ["chk_mv_table_name", { "type" => "check" }] }

      it { is_expected.to be_truthy }
    end

    describe "#when incorrect" do
      let(:route) { ["chk_mv_table_name_1", { "type" => "check" }] }

      it { is_expected.to be_falsey }
    end
  end
end