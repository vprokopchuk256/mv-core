require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'

describe Mv::Core::Constraint::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:index) { described_class.new(:idx_mv_table_name, {}) }

  describe "#initialize" do
    its(:options) { is_expected.to eq({}) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#register" do
    subject { index.register(migration_validator) }

    describe "when one of the routes leads to the current constraint" do
      let(:migration_validator) {
        create(:migration_validator, constraints: [[:idx_mv_table_name, :index, {}]])
      }

      it { is_expected.to eq([:idx_mv_table_name, :index, {}]) }

      it "adds validator to the constraint" do
        expect{ subject }.to change(index.validators, :count).by(1)
      end
    end

    describe "when no routes leads to the current constraint" do
      let(:migration_validator) {
        create(:migration_validator, constraints: [[:idx_mv_table_name_1, :index, {}]])
      }

      it { is_expected.to be_nil }

      it "does not add validator to the constraint" do
        expect{ subject }.not_to change(index.validators, :count)
      end
    end
  end
end