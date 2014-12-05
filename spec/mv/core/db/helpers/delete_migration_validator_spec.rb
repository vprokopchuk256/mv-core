require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/delete_migration_validator'

describe Mv::Core::Db::Helpers::DeleteMigrationValidator do
  let(:instance) do
    Class.new do
      include Mv::Core::Db::Helpers::DeleteMigrationValidator
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

  describe "when validator exists" do
    subject { instance.delete_migration_validator :table_name, :column_name, :uniqueness }

    it { is_expected.to be_truthy }
    
    it "does nothing" do
      expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
    end
    
  end

  describe "when validator does not exist" do
    subject { instance.delete_migration_validator :table_name, :column_name_1, :uniqueness }

    it { is_expected.to be_falsey }
    
    it "does nothing" do
      expect{ subject }.not_to change(Mv::Core::Db::MigrationValidator, :count)
    end
  end
end