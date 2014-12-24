require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/base'

describe Mv::Core::Router::Base do
  let(:migration_validator) { create(:migration_validator) }

  subject(:router) { described_class }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    subject(:route) { router.route(validation) }

    describe "default routing map" do
      describe "uniqueness" do
        let(:validation) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :index) }

        it "routes to index" do
          expect(router.instance.factory).to receive(:create_router).with(:index).and_call_original
          route
        end
      end

      describe "length" do
        let(:validation) { Mv::Core::Validation::Length.new(:table_name, :column_name, as: :trigger) }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "inclusion" do
        let(:validation) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, as: :trigger) }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "exclusion" do
        let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, as: :trigger) }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "presence" do
        let(:validation) { Mv::Core::Validation::Presence.new(:table_name, :column_name, as: :trigger) }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end  

      describe "format" do
        let(:validation) { Mv::Core::Validation::Format.new(:table_name, :column_name, as: :trigger) }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end
    end
  end
end   
