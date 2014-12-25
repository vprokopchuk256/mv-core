require 'spec_helper'

require 'mv/core/services/compare_constraints'
require 'mv/core/constraint/description'
require 'mv/core/constraint/check'
require 'mv/core/validation/uniqueness'
require 'mv/core/validation/presence'

describe Mv::Core::Services::CompareConstraints do
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
    old_constraint.validations << presence

    new_constraint.validations << uniqueness
  end

  subject(:compare) { described_class.new(old_constraints, new_constraints) }

  describe "#initialize" do
    let(:old_constraints) { [old_constraint] }
    let(:new_constraints) { [new_constraint] }

    its(:old_constraints) { is_expected.to eq(old_constraints)}
    its(:new_constraints) { is_expected.to eq(new_constraints)}
  end

  describe "#execute" do
    subject { compare.execute }

    describe "when constraint was deleted" do
      let(:old_constraints) { [old_constraint] }
      let(:new_constraints) { [] }

      it { is_expected.to eq({ deleted: [old_constraint] }) }
    end

    describe "when constraint was added" do
      let(:old_constraints) { [] }
      let(:new_constraints) { [new_constraint] }
      
      it { is_expected.to eq({ added: [new_constraint] }) }
    end

    describe "when constraint was updated" do
      let(:old_constraints) { [old_constraint] }
      let(:new_constraints) { [new_constraint] }
      
      it { is_expected.to eq({ updated: [[old_constraint, new_constraint]] }) }
    end

    describe "when nothing was changed" do
      let(:old_constraints) { [old_constraint] }
      let(:new_constraints) { [old_constraint] }

      it { is_expected.to be_blank }
    end
  end
end