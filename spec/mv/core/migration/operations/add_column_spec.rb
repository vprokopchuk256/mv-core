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
    describe "with full options hash" do
      subject(:operation){ described_class.new(:table_name, :column_name, uniqueness: { as: :trigger}).execute }
      
      it "creates new migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end

      describe "newly created validator" do
        subject(:validator) do
          operation
          Mv::Core::Db::MigrationValidator.last
        end

        its(:table_name) { is_expected.to eq('table_name') }
        its(:column_name) { is_expected.to eq('column_name') }
        its(:validator_name) { is_expected.to eq('uniqueness') }
        its(:options) { is_expected.to eq(as: :trigger) }
      end
    end

    describe "with true as create validator instruction" do
      subject(:operation){ described_class.new(:table_name, :column_name, uniqueness: true).execute }
      
      it "creates new migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end

      describe "newly created validator" do
        subject(:validator) do
          operation
          Mv::Core::Db::MigrationValidator.last
        end

        its(:options) { is_expected.to eq({}) }
      end
    end

    describe "with false as delete validator instruction" do
      subject(:operation){ described_class.new(:table_name, :column_name, uniqueness: false).execute }

      it "raised an error" do
        expect{ operation }.to raise_error(Mv::Core::Error)
      end
      
    end

    describe "when such validator exists already" do
      let!(:validator) do
        Mv::Core::Db::MigrationValidator.create!(table_name: :table_name, 
                                                 column_name: :column_name, 
                                                 validator_name: :uniqueness, 
                                                 options: { is: 5})
      end

      subject(:operation){ described_class.new(:table_name, :column_name, uniqueness: { is: 6}).execute }

      it "updates existing validator" do
        expect{ operation }.to change{validator.reload.options}.from(is: 5).to(is: 6)
      end
    end
  end
end