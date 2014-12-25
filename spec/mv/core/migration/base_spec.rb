require 'spec_helper'

require 'mv/core/db/migration_validator'
require 'mv/core/migration/operations/factory'
require 'mv/core/services/create_migration_validators_table'
require 'mv/core/migration/base'

describe Mv::Core::Migration::Base do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:migration) { described_class.current }

  describe "#add_column" do
    subject(:add_column) {
      migration.add_column :table_name, :column_name, length: { is: 5 } 
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :add_column, :table_name, :column_name, length: { is: 5 }
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#remove_column" do
    subject(:remove_column) {
      migration.remove_column :table_name, :column_name 
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :remove_column, :table_name, :column_name
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#rename_column" do
    subject(:rename_column) {
      migration.rename_column :table_name, :old_column_name, :new_column_name 
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :rename_column, :table_name, :old_column_name, :new_column_name
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#change_column" do
    subject(:change_column) {
      migration.change_column :table_name, :column_name, length: { is: 5 }  
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :change_column, :table_name, :column_name, length: { is: 5 }
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#rename_table" do
    subject(:rename_table) {
      migration.rename_table :old_table_name, :new_table_name
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :rename_table, :old_table_name, :new_table_name
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#drop_table" do
    subject(:drop_table)  {
      migration.drop_table :table_name
    }

    it "adds operation to the list" do
      expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
        :drop_table, :table_name
      ).and_call_original


      expect(migration.operations_list).to receive(:add_operation)

      subject
    end
  end

  describe "#execute" do
    subject(:migration_execute) { migration.execute }

    it "should call list execute" do
      expect(migration.operations_list).to receive(:execute)  
      
      subject
    end

  end
end