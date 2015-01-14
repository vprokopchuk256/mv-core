require 'spec_helper'

require 'mv/core/services/synchronize_constraints'
require 'mv/core/constraint/trigger'
require 'mv/core/constraint/builder/trigger'

describe Mv::Core::Services::SynchronizeConstraints do
  let(:description) { 
    Mv::Core::Constraint::Description.new(:trg_mv_table_name_ins, 
                                          :trigger, 
                                          event: :create)
  }

  let(:uniqueness) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :trigger, on: :create)}
  let(:presence) { Mv::Core::Validation::Presence.new(:table_name, :column_name, as: :trigger, on: :create)}

  let(:old_constraint) { Mv::Core::Constraint::Trigger.new(description)}
  let(:new_constraint) { Mv::Core::Constraint::Trigger.new(description)}

  before do
    old_constraint.validations << uniqueness
    new_constraint.validations << presence
  end

  describe "#execute" do
    subject(:execute) { sync.execute }

    describe "deletions" do
      let(:sync) { described_class.new(nil, nil, [old_constraint])}

      it "calls #delete on old constraint" do
        builder = double

        expect(builder).to receive(:delete)
        expect(Mv::Core::Constraint::Builder::Trigger).to receive(:new).with(old_constraint).and_return(builder)
        expect(Mv::Core::Services::SayConstraintsDiff).to receive(:new).with(*[old_constraint, nil]).and_call_original

        execute
      end
    end

    describe "updates" do
      let(:sync) { described_class.new(nil, [[old_constraint, new_constraint]], nil)}

      it "calls #update on old_constraint" do
        builder = double

        expect(builder).to receive(:update)
        expect(Mv::Core::Constraint::Builder::Trigger).to receive(:new).twice.and_return(builder)
        expect(Mv::Core::Services::SayConstraintsDiff).to receive(:new).with(*[old_constraint, new_constraint]).and_call_original

        execute
      end
    end

    describe "additions" do
      let(:sync) { described_class.new([new_constraint], nil, nil)}

      it "calls #create on old constraint" do
        builder = double

        expect(builder).to receive(:create)
        expect(Mv::Core::Constraint::Builder::Trigger).to receive(:new).with(new_constraint).and_return(builder)
        expect(Mv::Core::Services::SayConstraintsDiff).to receive(:new).with(*[nil, new_constraint]).and_call_original

        execute
      end
    end
  end
end