require 'spec_helper'

require 'mv/core/services/say_constraints_diff'

describe Mv::Core::Services::SayConstraintsDiff do
  let(:constraint_description) { 
    Mv::Core::Constraint::Description.new(:trg_table_name_upd, :trigger, event: :update)
  }

  let(:constraint_presenter) {
    Mv::Core::Presenter::Constraint::Description.new(constraint_description)
  }

  let(:old_constraint) { Mv::Core::Constraint::Trigger.new(constraint_description) }
  let(:new_constraint) { Mv::Core::Constraint::Trigger.new(constraint_description) }

  let(:uniqueness) { 
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name, 
                                         as: :trigger)
  }

  let(:validation_presenter) {
    Mv::Core::Presenter::Validation::Base.new(uniqueness)
  }

  describe "#initialize" do
    subject { described_class.new(old_constraint, new_constraint) }

    its(:old_constraint) { is_expected.to eq(old_constraint) }
    its(:new_constraint) { is_expected.to eq(new_constraint) }
  end

  describe "#execute" do
    describe "when new constraint is not provided" do
      before { old_constraint.validations << uniqueness }

      subject do 
        described_class.new(old_constraint, nil).execute do 
          ::ActiveRecord::Migration.say('internal code')
        end
      end

      it "outputs constraint description as deleted and it's validations as deleted" do
        expect(::ActiveRecord::Migration).to receive(:say_with_time).with("delete #{constraint_presenter} on table \"table_name\"").and_call_original
        expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("delete #{validation_presenter}", true)
        expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("internal code")
        subject
      end
    end

    describe "when old constraint is not provided" do
      before { new_constraint.validations << uniqueness }

      subject do 
        described_class.new(nil, new_constraint).execute do
          ::ActiveRecord::Migration.say('internal code')
        end
      end

      it "outputs constraint description as added and it's validations as added" do
        expect(::ActiveRecord::Migration).to receive(:say_with_time).with("create #{constraint_presenter} on table \"table_name\"").and_call_original
        expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("create #{validation_presenter}", true)
        expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("internal code")
        subject
      end
    end

    describe "when both new & old constraints are provided" do
      subject do 
        described_class.new(old_constraint, new_constraint).execute do
          ::ActiveRecord::Migration.say('internal code')
        end
      end

      describe "when old constrains contains validation that is not included to the new one" do
        before { old_constraint.validations << uniqueness }

        it "outputs constraint description as deleted and it's validations as deleted" do
          expect(::ActiveRecord::Migration).to receive(:say_with_time).with("update #{constraint_presenter} on table \"table_name\"").and_call_original
          expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("delete #{validation_presenter}", true)
          expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("internal code")
          subject
        end
      end

      describe "when new constraint contains validation that is not included to the old one" do
        before { new_constraint.validations << uniqueness }

        it "outputs constraint description as added and it's validations as added" do
          expect(::ActiveRecord::Migration).to receive(:say_with_time).with("update #{constraint_presenter} on table \"table_name\"").and_call_original
          expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("create #{validation_presenter}", true)
          expect(::ActiveRecord::Migration).to receive(:say).once.ordered.with("internal code")
          subject
        end
      end

      describe "when both new & old constraint has the same validations list" do
        before { 
          new_constraint.validations << uniqueness 
          old_constraint.validations << uniqueness 
        }

        it "outputs nothing" do
          expect(::ActiveRecord::Migration).not_to receive(:say)
          subject
        end
      end
    end
  end
end