require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/migration/operations/change_column'

describe Mv::Core::Migration::Operations::ChangeColumn do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:operation) { described_class.new(:table_name, :column_name, options ) }

  describe "#initialize" do
    let(:options) { { length: {is: 5} } }

    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:opts) { is_expected.to eq(length: { is: 5 }) }
  end

  describe "#execute" do
    describe "when opts are defined" do
      let(:options) { { length: {is: 5} } }

      it "calls update_column_validator method with proper parameters" do
        expect(operation).to receive(:update_column_validator).with(:length, { is: 5 })
                                                              .and_call_original
        operation.execute
      end
    end
    
    describe "when opts are not defined" do
      let(:options) { {} }

      describe "when validations are defined for the column" do
        before { create(:migration_validator) }

        it "deletes validators" do
          expect(operation).to receive(:delete_column_validator).and_call_original
          operation.execute
        end
      end

      describe "when validations are NOT defined for the column" do
        it "does not update validators" do
          expect(operation).not_to receive(:update_column_validator)
          operation.execute
        end

        it "does not delete validators" do
          expect(operation).not_to receive(:delete_column_validator)
          operation.execute
        end
      end
    end
  end
end