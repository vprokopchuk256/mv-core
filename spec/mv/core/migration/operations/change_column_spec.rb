require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/migration/operations/change_column'

describe Mv::Core::Migration::Operations::ChangeColumn do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#initialize" do
    subject { described_class.new(:table_name, :column_name, length: { is: 5} ) }

    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:opts) { is_expected.to eq(length: { is: 5 }) }
  end

  describe "#execute" do
    let!(:migration_validator) do  
      Mv::Core::Db::MigrationValidator.create!(table_name: :table_name, 
                                               column_name: :column_name, 
                                               validator_name: :uniqueness, 
                                               options: { as: :index } )
    end

    subject(:execute) { operation.execute }

    describe "when validator exists and ought to be removed" do
      let(:operation) { described_class.new(:table_name, :column_name, uniqueness: false) }

      it "deletes specified validator" do
        expect(operation).to receive(:delete_migration_validator).with(:uniqueness)
                                                                 .and_call_original
        execute
      end
    end

    describe "when validator does not exist and ought to be added" do
      let(:operation) { described_class.new(:table_name, :column_name_1, uniqueness: { as: :index}) }

      it "adds specified validator" do
        expect(operation).to receive(:create_migration_validator).with(:uniqueness, as: :index)
                                                                 .and_call_original
        execute
      end
    end

    describe "when validator exists and ought to be updated" do
      let(:operation) { described_class.new(:table_name, :column_name, uniqueness: { as: :trigger}) }

      it "adds specified validator" do
        expect(operation).to receive(:update_migration_validator).with(:uniqueness, as: :trigger)
                                                                 .and_call_original
        execute
      end

    end
  end
end