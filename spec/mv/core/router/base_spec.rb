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
    subject(:route) { router.route(:table_name, :column_name, validator_name, options) }

    describe "default routing map" do
      let(:options) { {} }

      describe "uniqueness" do
        let(:validator_name) { :uniqueness }

        it "routes to index" do
          expect(router.instance.factory).to receive(:create_router).with(:index).and_call_original
          route
        end
      end

      describe "length" do
        let(:validator_name) { :length }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "inclusion" do
        let(:validator_name) { :inclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "exclusion" do
        let(:validator_name) { :exclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "presence" do
        let(:validator_name) { :exclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end  

      describe "format" do
        let(:validator_name) { :format }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "undefined validator_name" do
        let(:validator_name) { :some_strange_validator }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end
    end

    describe "explicitly defined route" do
      let(:options) { { as: :trigger } }
      let(:validator_name) { :uniqueness }
      
      it "routes to defined route" do
        expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
        route
      end
    end

    describe "custom defaul route" do
      let(:options) { {} }
      let(:validator_name) { :uniqueness }

      before { router.instance.set_route(:uniqueness, :trigger) }

      it "routes to index" do
        expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
        route
      end
    end
  end
end   
