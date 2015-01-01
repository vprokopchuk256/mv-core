require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/factory'

describe Mv::Core::Constraint::Factory do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#create_constraint" do
    subject { described_class.create_constraint(description) }

    describe "by default" do
      describe "trigger" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:update_trigger_name, :trigger) 
        }

        it { is_expected.to be_instance_of(Mv::Core::Constraint::Trigger) }
      end

      describe "check" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:update_trigger_name, :check) 
        }

        it { is_expected.to be_instance_of(Mv::Core::Constraint::Check) }
      end

      describe "index" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:update_trigger_name, :index) 
        }

        it { is_expected.to be_instance_of(Mv::Core::Constraint::Index) }
      end
    end

    describe "when custom constraint provided" do
      let(:klass) { Class.new(Mv::Core::Constraint::Trigger) }

      let(:description) { 
        Mv::Core::Constraint::Description.new(:update_trigger_name, :trigger) 
      }

      before { described_class.register_constraint(:trigger, klass) }
      
      it { is_expected.to be_instance_of(klass) }
    end
  end
end