
require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/column_validators'

describe Mv::Core::Db::Helpers::TableValidators do
  let(:instance) do
    Class.new do
      include Mv::Core::Db::Helpers::TableValidators

      def initialize
        self.table_name = :table_name
      end
    end.new
  end

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let!(:migration_validator) { create(:migration_validator) }

  describe "#delete_table_validators" do
    subject(:delete_table_validators) { instance.delete_table_validators }

    describe "when validator exists" do
      it "deletes validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end

      it "say something to migration log" do
        expect(::ActiveRecord::Migration).to receive(:say).with("remove validation(#{Mv::Core::Presenter::MigrationValidator.new(migration_validator)}) on table_name.column_name")
        delete_table_validators
      end
    end

    describe "when other table validator exist" do
      before do
        migration_validator.update_attribute(:table_name, :table_name_1)
      end
      
      it "does not delete validator" do
        expect{ subject }.not_to change(Mv::Core::Db::MigrationValidator, :count)
      end
    end
  end

  describe "update_table_validators" do
    subject(:update_table_validators) { instance.update_table_validators(:table_name_2) }

    describe "when validator exists" do
      it "updates validator" do
        expect{ subject }.to change{migration_validator.reload.table_name}.from("table_name").to("table_name_2")
      end
    end

    describe "when other table validator exist" do
      before do
        migration_validator.update_attribute(:table_name, :table_name_1)
      end
      
      it "does not update validator" do
        expect{ subject }.not_to change{migration_validator.reload.table_name}
      end
    end
  end
end