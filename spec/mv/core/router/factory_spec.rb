require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/factory'

describe Mv::Core::Router::Factory do
  subject(:factory) { described_class.new }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#create_router" do
    subject(:create_router) { factory.create_router(constraint_type) }

    describe "#trigger" do
      let(:constraint_type) { :trigger }

      it "initializes router with table_name, column_name, and options and returns correct instance" do
        expect(Mv::Core::Router::Trigger).to receive(:new).and_call_original
        create_router
      end

      it { is_expected.to be_instance_of(Mv::Core::Router::Trigger) }
    end

    describe "#check" do
      let(:constraint_type) { :check }

      it "initializes router with table_name, column_name, and options and returns correct instance" do
        expect(Mv::Core::Router::Check).to receive(:new).and_call_original
        create_router
      end

      it { is_expected.to be_instance_of(Mv::Core::Router::Check) }
    end

    describe "#index" do
      let(:constraint_type) { :index }

      it "initializes router with table_name, column_name, and options and returns correct instance" do
        expect(Mv::Core::Router::Index).to receive(:new).and_call_original
        create_router
      end

      it { is_expected.to be_instance_of(Mv::Core::Router::Index) }
    end
  end
end