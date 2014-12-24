require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/db/migration_validator'

describe Mv::Core::Db::MigrationValidator do
  subject(:migration_validator) { 
    described_class.create(table_name: :table_name, 
                           column_name: :column_name, 
                           validation_type: :uniqueness, 
                           options: { as: :trigger, update_trigger_name: :update_trigger_name})
  }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq("table_name") }
    its(:column_name) { is_expected.to eq("column_name") }
    its(:validation_type) { is_expected.to eq("uniqueness") }
    its(:options) { is_expected.to eq({ as: :trigger, update_trigger_name: :update_trigger_name}) }
  end

  describe "db" do
    it { is_expected.to have_db_column(:table_name).with_options(null: false) }
    it { is_expected.to have_db_column(:column_name).with_options(null: false) }
    it { is_expected.to have_db_column(:validation_type).with_options(null: false) }
    it { is_expected.to have_db_column(:options) }
  end

  describe "options" do
    describe "when empty" do
      before do
        migration_validator.update_attributes(options: nil)
      end

      it "initialized by empty hash by default" do
        expect(migration_validator.options).to eq({})
      end
    end
  end

  describe "#validation" do
    subject { migration_validator.validation }

    it { is_expected.not_to be_nil }

    describe "when not valid" do
      before do
        migration_validator.options[:as] = :check
      end

      it "invalidatates migration_validator" do
        migration_validator.valid?
        expect( migration_validator ).to be_invalid
      end
    end
  end
end