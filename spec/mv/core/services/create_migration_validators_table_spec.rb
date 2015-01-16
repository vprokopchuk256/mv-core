require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'

describe Mv::Core::Services::CreateMigrationValidatorsTable do
  describe "#execute" do
    subject(:create_migration_validators_table) { described_class.new.execute }

    describe "when table does not exist" do
      it "creates it" do
        expect { subject }.to change{
          ActiveRecord::Base.connection.table_exists?(:migration_validators)
        }.from(false).to(true)
      end

      it "says that table is created" do
        expect(::ActiveRecord::Migration).to receive(:say_with_time).with('initialize migration_validators table')
        subject
      end
    end

    describe "when table already exist" do
      before do
        create_migration_validators_table
      end

      it "does not raise an error" do
        expect{ subject }.not_to raise_error
      end

      it "says nothing" do
        expect(::ActiveRecord::Migration).not_to receive(:say_with_time)
        subject
      end
    end
  end
end