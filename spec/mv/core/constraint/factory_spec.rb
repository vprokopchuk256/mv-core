require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/factory'

describe Mv::Core::Constraint::Factory do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#create_constraints" do
    describe "#trigger" do
      describe "one route" do
        subject(:create_constraints) { 
          described_class.new.create_constraints([
            [:update_trigger_name, :trigger, { event: :update }]
          ])
        }

        its(:length) { is_expected.to eq(1) }
        its(:first) { is_expected.to be_instance_of(Mv::Core::Constraint::Trigger) }
      end

      describe "two routes" do
        subject(:create_constraints) { 
          described_class.new.create_constraints([
            [:update_trigger_name, :trigger, { event: :update }],
            [:create_trigger_name, :trigger, { event: :create }] 
          ])
        }

        its(:length) { is_expected.to eq(2) }
      end
    end    

    describe "#check" do
      subject(:create_constraints) { 
        described_class.new.create_constraints([[:check_name, :check, {}]])
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraint::Check) }
    end    

    describe "#index" do
      subject(:create_constraints) { 
        described_class.new.create_constraints([[:check_name, :index, {}]])
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraint::Index) }
    end    
  end 

  describe "#load_constraints" do
    let!(:migration_validator) {
      create(:migration_validator, constraints: [
        [:update_trigger_name, :trigger, { event: :update }],
        [:create_trigger_name, :trigger, { event: :create }]
      ])
    }

    subject(:load_constraints) { described_class.new.load_constraints Mv::Core::Db::MigrationValidator.all }

    its(:length) { is_expected.to eq(2) }

    describe "distributes validators among 2 constraints" do
      describe "first constraint" do
        subject { load_constraints.first }

        its(:name) { is_expected.to eq(:update_trigger_name) }
        its(:event) { is_expected.to eq(:update) }
      end

      describe "last constraint" do
        subject { load_constraints.last }

        its(:name) { is_expected.to eq(:create_trigger_name) }
        its(:event) { is_expected.to eq(:create) }
      end
    end
  end
end