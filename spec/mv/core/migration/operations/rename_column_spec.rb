require 'spec_helper'

require 'mv/core/migration/operations/rename_column'

describe Mv::Core::Migration::Operations::RenameColumn do
  subject(:rename_column) do
    described_class.new(:table_name, :column_name, :new_column_name)
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:new_column_name) { is_expected.to eq(:new_column_name) }
  end

  describe "#execute" do
    let(:migration_validator) do
      Mv::Core::Db::MigrationValidator.create!(table_name: :table_name, 
                                               column_name: :column_name, 
                                               validator_name: :uniqueness, 
                                               options: true)
    end

    it "should call rename_column method internally" do
      expect(rename_column).to receive(:rename_column).with(:new_column_name)
      rename_column.execute
    end
  end
end