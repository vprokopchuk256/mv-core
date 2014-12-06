require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/migration/operations/add_column'

describe Mv::Core::Migration::Operations::AddColumn do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  subject(:operation) do
    described_class.new(:table_name, :column_name, length: { is: 5})
  end

  describe '#initialize' do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:opts) { is_expected.to eq(length: { is: 5 }) }
  end

  describe '#execute' do
    subject(:execute){ operation.execute }

    it "should create migration validators" do
      expect(operation).to receive(:create_migration_validator).with(
        :length, is: 5
      ).and_call_original
      execute
    end
  end
end