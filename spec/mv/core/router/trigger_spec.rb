require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/trigger'

describe Mv::Core::Router::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    subject { described_class.new.route(migration_validator) }

    describe "when validation event is not defined" do
      describe "when neither create_trigger_name nor update_trigger_name are not defined" do
        let(:migration_validator) { create(:migration_validator, options: {as: :trigger}) }
        
      end

      describe "when create_trigger name is defined" do
        
      end

      describe "when update_trigger name is defined" do
        
      end
    end

    describe "when validation event == :save" do
      
    end

    describe "when validation event == :create" do
      
    end

    describe "when validation event == :update" do
      
    end
  end
end