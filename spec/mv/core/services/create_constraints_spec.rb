require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/services/create_constraints'

describe Mv::Core::Services::CreateConstraints do
  let(:migration_validator) { 
    create(:migration_validator, table_name: :table_name, 
                                 validation_type: :uniqueness, 
                                 options: { as: :index }) 
  }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    migration_validator
  end

  subject(:service) { described_class.new(tables) }

  describe "#initialize" do
    describe "when tables list specified" do
      let(:tables) { [:table_name_1] }

      its(:tables) { is_expected.to eq([:table_name_1]) }
    end

    describe "when tables list not specified" do
      let(:tables) { [] }

      its(:tables) { is_expected.to eq(["table_name"]) }
    end
  end

  describe "#execute" do
    describe "when existing table name specified" do
      let(:tables) { [:table_name] }

      subject { service.execute }

      it "should remove constraints on the specified tables" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Index).to receive(:create)

        subject      
      end
    end

    describe "when not existing table of table without constraints specified" do
      let(:tables) { [:table_name_1] }

      subject { service.execute }

      it "should remove constraints on the specified tables" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Index).not_to receive(:create)

        subject      
      end
    end
  end
end