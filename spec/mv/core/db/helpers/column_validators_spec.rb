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

  let!(:migration_validator) do
    Mv::Core::Db::MigrationValidator.create!(table_name: :table_name, 
                                             column_name: :column_name, 
                                             validator_name: :uniqueness, 
                                             options: { as: :trigger })
  end

  describe "#create_column_validator" do
    describe 'when remove validator directive is specified' do
      subject { instance.create_column_validator(:uniqueness, false) }

      it { is_expected.to be_nil }

      it 'does nothing' do
        expect{ subject }.not_to change(Mv::Core::Db::MigrationValidator, :count)
      end
    end

    describe 'simple add validator directive is passed' do
      subject do
        instance.create_column_validator(:uniqueness, true).reload
      end

      its(:table_name) { is_expected.to eq('table_name') }
      its(:column_name) { is_expected.to eq('column_name') }
      its(:validator_name) { is_expected.to eq('uniqueness') }
      its(:options) { is_expected.to eq({}) }

      it 'should add one validator to the table' do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end
    end

    describe 'validator with options is passed' do
      subject { instance.create_column_validator(:length, is: 5).reload }

      its(:table_name) { is_expected.to eq('table_name') }
      its(:column_name) { is_expected.to eq('column_name') }
      its(:validator_name) { is_expected.to eq('length') }
      its(:options) { is_expected.to eq(is: 5) }

      it 'should add one validator to the table' do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
      end
    end
  end

  describe "#update_column_validator" do
    describe 'when remove validator directive is specified' do
      subject { instance.update_column_validator(:uniqueness, false) }

      it { is_expected.to be_falsey }

      it 'does nothing' do
        expect{ subject }.not_to change{ migration_validator.options }
      end
    end

    describe 'simple add validator directive is passed' do
      subject { instance.update_column_validator(:uniqueness, true) }


      it { is_expected.to be_truthy }

      it 'changes validator options accordingly' do
        expect{ subject }.to change{ migration_validator.reload.options }.from(as: :trigger).to({})
      end
    end

    describe 'validator with options is passed' do
      subject { instance.update_column_validator(:uniqueness, as: :index) }

      it { is_expected.to be_truthy }

      it 'changes validator options accordingly' do
        expect{ subject }.to change{ migration_validator.reload.options }.from(as: :trigger).to(as: :index)
      end
    end

    describe 'non existing validator options is passed' do
      subject { instance.update_column_validator(:uniqueness, as: :index) }

      before do
        migration_validator.update_attributes(column_name: :column_name_1)
      end

      it { is_expected.to be_falsey }

      it 'does nothing' do
        expect{ subject }.not_to change{ migration_validator.options }
      end
    end
  end

  describe "#delete_column_validator" do
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