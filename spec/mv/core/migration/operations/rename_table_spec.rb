require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/migration/operations/rename_table'

describe Mv::Core::Migration::Operations::RenameTable do
  subject(:rename_table_operation) do
    described_class.new(:table_name, :new_table_name)
  end

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:new_table_name) { is_expected.to eq(:new_table_name) }
  end

  describe "#execute" do
    subject(:execute) { rename_table_operation.execute }

    it "should call delete_table_validators method" do
      expect(rename_table_operation).to receive(:update_table_validators)
                                        .with(:new_table_name)
                                        .and_call_original
      execute
    end
  end
end