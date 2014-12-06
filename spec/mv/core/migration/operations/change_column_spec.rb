require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/migration/operations/change_column'

describe Mv::Core::Migration::Operations::ChangeColumn do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:operation) { described_class.new(:table_name, :column_name, length: { is: 5} ) }

  describe "#initialize" do

    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:opts) { is_expected.to eq(length: { is: 5 }) }
  end

  describe "#execute" do
    it "calls update_column_validator method with proper parameters" do
      expect(operation).to receive(:update_column_validator).with(:length, { is: 5 })
                                                            .and_call_original
      operation.execute
    end
  end
end