require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/trigger'
require 'mv/core/error'

describe Mv::Core::Constraint::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:trigger_description) { Mv::Core::Constraint::Description.new(:update_trigger_name, 
                                                                    :trigger, 
                                                                    { event: :update })}

  subject(:trigger) { described_class.new(trigger_description) }

  describe "#initialize" do
    its(:description) { is_expected.to eq(trigger_description) }
    its(:validations) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#<=>" do
    let(:inclusion) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2], as: :trigger) }
    let(:exclusion) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [0, 3], as: :trigger) }

    before do
      trigger.validations << inclusion
      trigger.validations << exclusion
    end

    it { is_expected.to eq(trigger) }

    describe "when description is different" do
      let(:other_trigger_description) { Mv::Core::Constraint::Description.new(:trg_mv_table_name_1, :trigger) }
      let(:other_trigger) { described_class.new(other_trigger_description) }

      before do
        other_trigger.validations << inclusion
        other_trigger.validations << exclusion
      end
      
      it { is_expected.not_to eq(other_trigger) }
    end

    describe "when validations list contains different elements" do
      let(:other_trigger) { described_class.new(trigger_description) }

      before do
        other_trigger.validations << inclusion
      end
      
      it { is_expected.not_to eq(other_trigger) }
    end

    describe "when validations list sorted differently" do
      let(:other_trigger) { described_class.new(trigger_description) }

      before do
        other_trigger.validations << exclusion
        other_trigger.validations << inclusion
      end
      
      it { is_expected.to eq(other_trigger) }
    end

    describe "when description and validations list are the same" do
      let(:other_trigger) { described_class.new(trigger_description) }

      before do
        other_trigger.validations << inclusion
        other_trigger.validations << exclusion
      end
      
      it { is_expected.to eq(other_trigger) }
    end
  end
end