require 'spec_helper'

require 'mv/core/services/uninstall'

describe Mv::Core::Services::Uninstall do
  let(:migration_validator) { 
    create(:migration_validator, table_name: :table_name, 
                                 validation_type: :uniqueness, 
                                 options: { as: :index }) 
  }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    migration_validator
  end

  subject(:service) { described_class.new }

  describe "#execute" do
    subject { service.execute }

    it "removes constraints" do
      expect_any_instance_of(Mv::Core::Constraint::Builder::Index).to receive(:delete)

      subject      
    end

    it "removes migration_validators table" do
      expect{ subject }.to change{::ActiveRecord::Base.connection.table_exists?(:migration_validators)}.from(true).to(false)
    end

    describe "when migration validators table does not exist" do
      before do
        ::ActiveRecord::Base.connection.drop_table(:migration_validators)
      end

      it "should not raise an error" do
        expect{ subject }.not_to raise_error
      end
    end
  end
end