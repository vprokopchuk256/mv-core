require 'spec_helper'

describe Mv::Core::ActiveRecord::SchemaDumperDecorator do
  before do
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

    it { is_expected.to include("#{Mv::Core::Presenter::Validation::Base.new(migration_validator.validation)}")}
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