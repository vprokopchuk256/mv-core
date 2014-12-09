require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/migration/operations/add_column'

describe Mv::Core::Migration::Operations::AddColumn do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  describe '#initialize' do
    subject{ described_class.new(:table_name, :column_name, uniqueness: { as: :trigger }) }
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:opts) { is_expected.to eq(uniqueness: { as: :trigger }) }
  end

  describe '#execute' do
    describe "when opts are defined" do
      subject(:operation) do 
        described_class.new(:table_name, :column_name, uniqueness: { as: :trigger})
      end

      it "calls create_column_validator method" do
        expect(operation).to receive(:create_column_validator).with(:uniqueness, { as: :trigger })
                                                              .and_call_original
        operation.execute
      end
    end

    describe "when opts are not defined" do
      subject(:operation) do 
        described_class.new(:table_name, :column_name)
      end

      it "does not raise an error" do
        expect{ operation.execute }.not_to raise_error
      end
    end
  end
end