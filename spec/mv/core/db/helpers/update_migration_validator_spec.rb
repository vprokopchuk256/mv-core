require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/update_migration_validator'

describe Mv::Core::Db::Helpers::UpdateMigrationValidator do
  let(:instance) do
    Class.new do
      include Mv::Core::Db::Helpers::UpdateMigrationValidator
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

  describe 'when remove validator directive is specified' do
    subject { instance.update_migration_validator(:table_name, :column_name, :uniqueness, false) }

    it { is_expected.to be_falsey }

    it 'does nothing' do
      expect{ subject }.not_to change{ migration_validator.options }
    end
  end

  describe 'simple add validator directive is passed' do
    subject { instance.update_migration_validator(:table_name, :column_name, :uniqueness, true) }


    it { is_expected.to be_truthy }

    it 'changes validator options accordingly' do
      expect{ subject }.to change{ migration_validator.reload.options }.from(as: :trigger).to({})
    end
  end

  describe 'validator with options is passed' do
    subject { instance.update_migration_validator(:table_name, :column_name, :uniqueness, as: :index) }

    it { is_expected.to be_truthy }

    it 'changes validator options accordingly' do
      expect{ subject }.to change{ migration_validator.reload.options }.from(as: :trigger).to(as: :index)
    end
  end

  describe 'non existing validator options is passed' do
    subject { instance.update_migration_validator(:table_name, :column_name_1, :uniqueness, as: :index ) }

    it { is_expected.to be_falsey }

    it 'does nothing' do
      expect{ subject }.not_to change{ migration_validator.options }
    end
  end
end