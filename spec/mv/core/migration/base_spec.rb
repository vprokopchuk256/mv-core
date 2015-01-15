require 'spec_helper'

require 'mv/core/migration/base'

describe Mv::Core::Migration::Base do
  subject(:migration) { described_class.current }

  describe "#add_column" do
    describe "when validations are defined" do
      subject(:add_column) {
        migration.add_column :table_name, :column_name, length: { is: 5 } 
      }

      it "adds operation to the list" do
        expect_any_instance_of(Mv::Core::Migration::Operations::Factory).to receive(:create_operation).with(
          :add_column, :table_name, :column_name, length: { is: 5 }
        ).and_call_original

        expect(migration.operations_list).to receive(:add_operation)
        add_column
      end
    end

    describe "when validaions are suppressed" do
      subject(:add_column) {
        migration.with_suppressed_validations do
          migration.add_column :table_name, :column_name, length: { is: 5 } 
        end
      }

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        add_column
      end
    end

    describe "when validations are NOT defined" do
      subject(:add_column) {
        migration.add_column :table_name, :column_name, nil
      }

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        add_column
      end
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

    describe "when validaions are suppressed" do
      subject(:remove_column) do
        migration.with_suppressed_validations do
          migration.remove_column :table_name, :column_name 
        end
      end

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        remove_column
      end
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

    describe "when validaions are suppressed" do
      subject(:rename_column) do
        migration.with_suppressed_validations do
          migration.rename_column :table_name, :old_column_name, :new_column_name 
        end
      end

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        rename_column
      end
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

    describe "when validaions are suppressed" do
      subject(:change_column) do
        migration.with_suppressed_validations do
          migration.change_column :table_name, :column_name, length: { is: 5 }  
        end
      end

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        change_column
      end
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

    describe "when validaions are suppressed" do
      subject(:rename_table) do
        migration.with_suppressed_validations do
          migration.rename_table :old_table_name, :new_table_name
        end
      end

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        rename_table
      end
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

    describe "when validaions are suppressed" do
      subject(:drop_table) do
        migration.with_suppressed_validations do
          migration.drop_table :table_name
        end
      end

      it "does NOT add any operation to the list" do
        expect(migration.operations_list).not_to receive(:add_operation)
        drop_table
      end
    end
  end

  describe "#execute" do
    subject(:migration_execute) { migration.execute }

    it "executes operations list" do
      expect(migration.operations_list).to receive(:execute)  
      
      subject
    end

    it "checks and creates migration table" do
      expect_any_instance_of(Mv::Core::Services::CreateMigrationValidatorsTable).to receive(:execute).and_call_original

      subject
    end
  end
end