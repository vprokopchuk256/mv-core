require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/column_validators'

describe Mv::Core::Db::Helpers::ColumnValidators do
  let(:instance) do
    Class.new do
      include Mv::Core::Db::Helpers::ColumnValidators

      def initialize
        self.table_name = :table_name
        self.column_name = :column_name
      end
    end.new
  end

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:migration_validator) do
    Mv::Core::Db::MigrationValidator.new(table_name: :table_name, 
                                         column_name: :column_name, 
                                         validator_name: :uniqueness, 
                                         options: { as: :trigger })
  end

  describe "#create_column_validator" do
     describe "with full options hash" do
      subject(:create_column_validator){ instance.create_column_validator(:uniqueness, { as: :trigger}) }
      
      it "creates new migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end

      describe "newly created validator" do
        subject(:validator) do
          create_column_validator
          Mv::Core::Db::MigrationValidator.last
        end

        its(:table_name) { is_expected.to eq('table_name') }
        its(:column_name) { is_expected.to eq('column_name') }
        its(:validator_name) { is_expected.to eq('uniqueness') }
        its(:options) { is_expected.to eq(as: :trigger) }
      end
    end

    describe "with true as create validator instruction" do
      subject(:create_column_validator){ instance.create_column_validator(:uniqueness, true) }
      
      it "creates new migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end

      describe "newly created validator" do
        subject(:validator) do
          create_column_validator
          Mv::Core::Db::MigrationValidator.last
        end

        its(:options) { is_expected.to eq({}) }
      end
    end

    describe "with false as delete validator instruction" do
      subject(:create_column_validator){ instance.create_column_validator(:uniqueness, false) }

      it "raised an error" do
        expect{ create_column_validator }.to raise_error(Mv::Core::Error)
      end
      
    end

    describe "when such validator exists already" do
      let!(:validator) do
        Mv::Core::Db::MigrationValidator.create!(table_name: :table_name, 
                                                 column_name: :column_name, 
                                                 validator_name: :uniqueness, 
                                                 options: { is: 5})
      end

      subject(:create_column_validator){ instance.create_column_validator(:uniqueness, { is: 6}) }

      it "updates existing validator" do
        expect{ create_column_validator }.to change{validator.reload.options}.from(is: 5).to(is: 6)
      end
    end
  end

  describe "#update_column_validator" do
    describe 'when validator is to be removed' do
      before { migration_validator.save! }

      subject(:update_column_validator) { instance.update_column_validator(:uniqueness, false) }

      it "should remove existing validator" do
        expect{ update_column_validator }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
    end

    describe 'when validator exists' do
      before { migration_validator.save! }

      subject(:update_column_validator) { instance.update_column_validator(:uniqueness, { as: :index }) }

      it "should update existing validator" do
        expect{ update_column_validator }.to change{ migration_validator.reload.options }.from(as: :trigger).to(as: :index)
      end
    end

    describe 'when validator does not exist' do
      subject(:update_column_validator) { instance.update_column_validator(:uniqueness, true) }

      it "should create new validator" do
        expect{ update_column_validator }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end
    end
  end

  describe "#delete_column_validator" do
    before { migration_validator.save! }

    describe "when validator exists" do
      subject { instance.delete_column_validator :uniqueness }

      it { is_expected.to be_truthy }
      
      it "does nothing" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
      
    end

    describe "when validator does not exist" do
      subject { instance.delete_column_validator :uniqueness }

      before do
        migration_validator.update_attributes(column_name: :column_name_1)
      end

      it { is_expected.to be_falsey }
      
      it "does nothing" do
        expect{ subject }.not_to change(Mv::Core::Db::MigrationValidator, :count)
      end
    end
  end 
end