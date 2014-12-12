require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraints/containers/check'
require 'mv/core/error'

describe Mv::Core::Constraints::Containers::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  subject(:check) { described_class.new(:chk_mv_table_name, { type: :check }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :check) }
    its(:name) { is_expected.to eq(:chk_mv_table_name) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#visit" do
    subject { check.visit(migration_validator) }

    describe "when one of the routes leads to the current container" do
      let(:migration_validator) {
        create(:migration_validator, containers: { chk_mv_table_name: { type: :check } })
      }

      it { is_expected.to eq([:chk_mv_table_name, { type: :check }]) }

      it "adds validator to the container" do
        expect{ subject }.to change(check.validators, :count).by(1)
      end
    end

    describe "when no routes leads to the current container" do
      let(:migration_validator) {
        create(:migration_validator, containers: { chk_mv_table_name_1: { type: :check } })
      }

      it { is_expected.to be_nil }

      it "does not add validator to the container" do
        expect{ subject }.not_to change(check.validators, :count)
      end
    end
  end
end