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
    subject(:route) { router.route(:table_name, :column_name, validation_type, options) }

    describe "default routing map" do
      let(:options) { {} }

      describe "uniqueness" do
        let(:validation_type) { :uniqueness }

        it "routes to index" do
          expect(router.instance.factory).to receive(:create_router).with(:index).and_call_original
          route
        end
      end

      describe "length" do
        let(:validation_type) { :length }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "inclusion" do
        let(:validation_type) { :inclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "exclusion" do
        let(:validation_type) { :exclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "presence" do
        let(:validation_type) { :exclusion }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end  

      describe "format" do
        let(:validation_type) { :format }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end

      describe "undefined validation_type" do
        let(:validation_type) { :some_strange_validator }

        it "routes to trigger" do
          expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
          route
        end
      end
    end

    describe "explicitly defined route" do
      let(:options) { { as: :trigger } }
      let(:validation_type) { :uniqueness }
      
      it "routes to defined route" do
        expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
        route
      end
    end

    describe "custom defaul route" do
      let(:options) { {} }
      let(:validation_type) { :uniqueness }

      before { router.instance.set_route(:uniqueness, :trigger) }

      it "routes to index" do
        expect(router.instance.factory).to receive(:create_router).with(:trigger).and_call_original
        route
      end
    end
  end
end   
