require 'spec_helper'

require 'mv/core/services/compare_constraints'

describe Mv::Core::Services::CompareConstraints do
  let(:constraint_description) { 
    Mv::Core::Constraint::Description.new(:trg_table_name_upd, :trigger, event: :update)
  }

  let(:old_constraint) { Mv::Core::Constraint::Trigger.new(constraint_description) }
  let(:new_constraint) { Mv::Core::Constraint::Trigger.new(constraint_description) }

  let(:uniqueness) { 
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name, 
                                         as: :trigger)
  }

  describe "#initialize" do
    subject { described_class.new(old_constraint, new_constraint) }

    its(:old_constraint) { is_expected.to eq(old_constraint) }
    its(:new_constraint) { is_expected.to eq(new_constraint) }
  end

  describe "when new constraint is not provided" do
    before { old_constraint.validations << uniqueness }

    subject { described_class.new(old_constraint, nil).execute }

    it { is_expected.to eq(
      deleted: [uniqueness]
    )}
  end

  describe "when old constraint is not provided" do
    before { new_constraint.validations << uniqueness }

    subject { described_class.new(nil, new_constraint).execute }

    it { is_expected.to eq(
      added: [uniqueness]
    )}
  end

  describe "when both new & old constraints are provided" do
    subject { described_class.new(old_constraint, new_constraint).execute }

    describe "when old constrains contains validation that is not included to the new one" do
      before { old_constraint.validations << uniqueness }

      it { is_expected.to eq(
        deleted: [uniqueness]
      )}
    end

    describe "when new constraint contains validation that is not included to the old one" do
      before { new_constraint.validations << uniqueness }

      it { is_expected.to eq(
        added: [uniqueness]
      )}
    end

    describe "when both new & old constraint has the same validations list" do
      before { 
        new_constraint.validations << uniqueness 
        old_constraint.validations << uniqueness 
      }

      it { is_expected.to be_empty }
    end
  end
end