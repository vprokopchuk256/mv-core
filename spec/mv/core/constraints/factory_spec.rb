require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraints/factory'

describe Mv::Core::Constraints::Factory do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#create_containers" do
    describe "#trigger" do
      describe "one route" do
        subject(:create_containers) { 
          described_class.new.create_containers(
            update_trigger_name: { type: :trigger, event: :update } 
          )
        }

        its(:length) { is_expected.to eq(1) }
        its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Trigger) }
      end

      describe "two routes" do
        subject(:create_containers) { 
          described_class.new.create_containers(
            update_trigger_name: { type: :trigger, event: :update },
            create_trigger_name: { type: :trigger, event: :create } 
          )
        }

        its(:length) { is_expected.to eq(2) }
      end
    end    

    describe "#check" do
      subject(:create_containers) { 
        described_class.new.create_containers(check_name: { type: :check })
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Check) }
    end    

    describe "#index" do
      subject(:create_containers) { 
        described_class.new.create_containers(check_name: { type: :index })
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Index) }
    end    
  end 

  describe "#load_containers" do
    let!(:migration_validator) {
      create(:migration_validator, containers: {
          update_trigger_name: { type: :trigger, event: :update },
          create_trigger_name: { type: :trigger, event: :create }
      })
    }

    subject(:load_containers) { described_class.new.load_containers Mv::Core::Db::MigrationValidator.all }

    its(:length) { is_expected.to eq(2) }

    describe "distributes validators among 2 containers" do
      describe "first container" do
        subject { load_containers.first }

        its(:name) { is_expected.to eq(:update_trigger_name) }
        its(:event) { is_expected.to eq(:update) }
      end

      describe "last container" do
        subject { load_containers.last }

        its(:name) { is_expected.to eq(:create_trigger_name) }
        its(:event) { is_expected.to eq(:create) }
      end
    end
  end
end