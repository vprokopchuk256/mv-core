require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/migration/operations/drop_table'

describe Mv::Core::Migration::Operations::DropTable do
  subject(:drop_table_operation) do
    described_class.new(:table_name)
  end
  
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
  end

  describe "#execute" do
    subject(:execute) { drop_table_operation.execute }

    it "should call delete_table_validators method" do
      expect(drop_table_operation).to receive(:delete_table_validators).and_call_original
      execute
    end
  end
end