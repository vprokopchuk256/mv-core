require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/create_migration_validator'

describe Mv::Core::Db::Helpers::CreateMigrationValidator do
  let(:instance) do
    Class.new do
      include Mv::Core::Db::Helpers::CreateMigrationValidator
    end.new
  end

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe 'when remove validator directive specified' do
    subject { instance.create_migration_validator(:table_name, :column_name, :uniqueness, false) }

    it { is_expected.to be_nil }

    it 'does nothing' do
      expect{ subject }.not_to change(Mv::Core::Db::MigrationValidator, :count)
    end
  end

  describe 'simple add validator directive passed' do
    subject do
      instance.create_migration_validator(:table_name, :column_name, :uniqueness, true).reload
    end

    its(:table_name) { is_expected.to eq('table_name') }
    its(:column_name) { is_expected.to eq('column_name') }
    its(:validator_name) { is_expected.to eq('uniqueness') }
    its(:options) { is_expected.to eq({}) }

    it 'should add one validator to the table' do
      expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
    end
  end

  describe 'validator with options passed' do
    subject { instance.create_migration_validator(:table_name, :column_name, :length, is: 5).reload }

    its(:table_name) { is_expected.to eq('table_name') }
    its(:column_name) { is_expected.to eq('column_name') }
    its(:validator_name) { is_expected.to eq('length') }
    its(:options) { is_expected.to eq(is: 5) }

    it 'should add one validator to the table' do
      expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(1)
    end
  end
end