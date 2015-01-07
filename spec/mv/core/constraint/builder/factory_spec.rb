require 'spec_helper'

require 'mv/core/constraint/builder/factory'

describe Mv::Core::Constraint::Builder::Factory do
  describe "#create_builder" do
    subject { described_class.create_builder(constraint) }

    describe "for index constraint" do
      let(:index_description) { Mv::Core::Constraint::Description.new(:idx_table_name, :index) }
      let(:constraint) { Mv::Core::Constraint::Index.new(index_description)}

      it { is_expected.to be_a_kind_of(Mv::Core::Constraint::Builder::Index) }
    end

    describe "for trigger constraint" do
      let(:trigger_description) { Mv::Core::Constraint::Description.new(:trg_table_name_upd, :trigger, event: :update) }
      let(:constraint) { Mv::Core::Constraint::Trigger.new(trigger_description)}
      
      it { is_expected.to be_a_kind_of(Mv::Core::Constraint::Builder::Trigger) }
    end

    describe "when custom constraint builder defined" do
      let(:trigger_description) { Mv::Core::Constraint::Description.new(:trg_table_name_upd, :trigger, event: :update) }
      let(:klass) { Class.new(Mv::Core::Constraint::Builder::Trigger) }
      let(:constraint) { Mv::Core::Constraint::Trigger.new(trigger_description)}

      before { described_class.register_builder(Mv::Core::Constraint::Trigger, klass) }

      it { is_expected.to be_a_kind_of(klass) }

      after { described_class.register_builder(Mv::Core::Constraint::Trigger, Mv::Core::Constraint::Builder::Trigger) }
    end
  end
end