require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'

describe Mv::Core::Constraint::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:index) { described_class.new(:idx_mv_table_name, { type: :index }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :index) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#container interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#register" do
    subject { index.register(migration_validator) }

    describe "when one of the routes leads to the current container" do
      let(:migration_validator) {
        create(:migration_validator, containers: { idx_mv_table_name: { type: :index } })
      }

      it { is_expected.to eq([:idx_mv_table_name, { type: :index }]) }

      it "adds validator to the container" do
        expect{ subject }.to change(index.validators, :count).by(1)
      end
    end

    describe "when no routes leads to the current container" do
      let(:migration_validator) {
        create(:migration_validator, containers: { idx_mv_table_name_1: { type: :index } })
      }

      it { is_expected.to be_nil }

      it "does not add validator to the container" do
        expect{ subject }.not_to change(index.validators, :count)
      end
    end
  end
end