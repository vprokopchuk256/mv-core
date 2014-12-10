require 'spec_helper'

require 'mv/core/constraints/containers/index'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Index do
  subject { described_class.new(:chk_mv_table_name, { type: :index }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :index) }
    its(:name) { is_expected.to eq(:chk_mv_table_name) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end
end