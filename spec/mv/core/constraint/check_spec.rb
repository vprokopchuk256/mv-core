require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/check'
require 'mv/core/error'

describe Mv::Core::Constraint::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:check_description) { Mv::Core::Constraint::Description.new(:chk_mv_table_name, :check)}

  subject(:check) { described_class.new(check_description) }

  describe "#initialize" do
    its(:description) { is_expected.to eq(check_description) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#register" do
    subject { check.register(migration_validator) }

    describe "when one of the routes leads to the current constraint" do
      let(:migration_validator) {
        create(:migration_validator, constraints: [[:chk_mv_table_name, :check, {}]])
      }

      it { is_expected.to eq([:chk_mv_table_name, :check, {}]) }

      it "adds validator to the constraint" do
        expect{ subject }.to change(check.validators, :count).by(1)
      end
    end

    describe "when no routes leads to the current constraint" do
      let(:migration_validator) {
        create(:migration_validator, constraints: [[:chk_mv_table_name_1, :check, {}]])
      }

      it { is_expected.to be_nil }

      it "does not add validator to the constraint" do
        expect{ subject }.not_to change(check.validators, :count)
      end
    end
  end
end