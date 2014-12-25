require 'spec_helper'

require 'mv/core/services/synchronize_constraints'
require 'mv/core/constraint/check'

describe Mv::Core::Services::SynchronizeConstraints do
  let(:description) { 
    Mv::Core::Constraint::Description.new(:chk_mv_table_name_column_name, 
                                          :check)
  }

  let(:uniqueness) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :check)}
  let(:presence) { Mv::Core::Validation::Presence.new(:table_name, :column_name, as: :check)}

  let(:old_constraint) { Mv::Core::Constraint::Check.new(description)}
  let(:new_constraint) { Mv::Core::Constraint::Check.new(description)}

  before do
    old_constraint.validations << uniqueness
    new_constraint.validations << presence
  end

  describe "#execute" do
    subject(:execute) { sync.execute }

    describe "deletions" do
      let(:sync) { described_class.new(nil, nil, [old_constraint])}

      it "calls #delete on old constraint" do
        expect(old_constraint).to receive(:delete).and_call_original
        execute
      end
    end

    describe "updates" do
      let(:sync) { described_class.new(nil, [[old_constraint, new_constraint]], nil)}

      it "calls #update on old_constraint" do
        expect(old_constraint).to receive(:update).with(*[new_constraint]).and_call_original
        execute
      end
    end

    describe "additions" do
      let(:sync) { described_class.new([new_constraint], nil, nil)}

      it "calls #delete on old constraint" do
        expect(new_constraint).to receive(:create).and_call_original
        execute
      end
    end
  end
end