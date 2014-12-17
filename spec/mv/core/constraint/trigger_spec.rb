require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/trigger'
require 'mv/core/error'

describe Mv::Core::Constraint::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:trigger) { described_class.new(:update_trigger_name, { type: :trigger, event: :update }) }

  describe "#initialize" do
    its(:options) { is_expected.to eq(type: :trigger, event: :update) }
    its(:name) { is_expected.to eq(:update_trigger_name) }
    its(:event) { is_expected.to eq(:update) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#register" do
    subject { trigger.register(migration_validator) }

    describe "when one of the routes leads to the current constraint" do
      let(:migration_validator) {
        create(
          :migration_validator, constraints: {
            update_trigger_name: { type: :trigger, event: :update },
            create_trigger_name: { type: :trigger, event: :create }
          }
        )
      }

      it { is_expected.to eq([:update_trigger_name, { type: :trigger, event: :update }]) }

      it "adds validator to the constraint" do
        expect{ subject }.to change(trigger.validators, :count).by(1)
      end
    end

    describe "when no routes leads to the current constraint" do
      let(:migration_validator) {
        create(
          :migration_validator, constraints: {
            update_trigger_name_1: { type: :trigger, event: :update },
            create_trigger_name_1: { type: :trigger, event: :create }
          }
        )
      }

      it { is_expected.to be_nil }

      it "does not add validator to the constraint" do
        expect{ subject }.not_to change(trigger.validators, :count)
      end
    end
  end
end