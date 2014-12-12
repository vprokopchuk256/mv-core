require 'spec_helper'

require 'mv/core/constraints/containers/index'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Index do
  subject(:index) { described_class.new(:idx_mv_table_name, { type: :index }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :index) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#routed_by?" do
    subject { index.routed_by?(*route) }

    describe "#when correct" do
      let(:route) { ["idx_mv_table_name", { "type" => "index" }] }

      it { is_expected.to be_truthy }
    end

    describe "#when incorrect" do
      let(:route) { ["idx_mv_table_name_1", { "type" => "index" }] }

      it { is_expected.to be_falsey }
    end
  end
end