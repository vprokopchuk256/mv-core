require 'spec_helper'

require 'mv/core/active_record/schema_dumper_decorator'

describe Mv::Core::ActiveRecord::SchemaDumperDecorator do
  before do
    ::ActiveRecord::SchemaDumper.send(:prepend, described_class)

    ::ActiveRecord::Migration.verbose = false
  end

  let(:out) { StringIO.new() }
  let(:dump) { ::ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, out) }

  describe "when migration_validators table exists" do
    let(:migration_validator) { create(:migration_validator) }

    before do
      Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
      migration_validator

      dump
    end

    subject { out.string }

    it { is_expected.to include("validates :table_name, :column_name, #{Mv::Core::Presenter::MigrationValidator.new(migration_validator)}")}
    it { is_expected.not_to include("create_table \"migration_validators\"") }
  end

  describe "when migration_validators table does not exist" do
    subject { dump } 

    it "should not raise an error" do
      expect{ subject }.not_to raise_error
    end

    it "should create migration_validators table" do
      expect{ subject }.to change{ ::ActiveRecord::Base.connection.table_exists?(:migration_validators) }.from(false).to(true)
    end
  end
end