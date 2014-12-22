require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/trigger'

describe Mv::Core::Router::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    subject { described_class.new.route(:table_name, :column_name, :validation_type, options) }

    describe "when validation event is not defined" do
      describe "when neither create_trigger_name nor update_trigger_name are not defined" do
        let(:options) { {as: :trigger} }
        
        it "routes to default update and insert trigger" do
          expect(subject).to eq([
            [:trg_mv_table_name_ins, :trigger, { event: :create }], 
            [:trg_mv_table_name_upd, :trigger, { event: :update }]
          ])
        end
      end

      describe "when create_trigger name is defined" do
        let(:options) { { as: :trigger, create_trigger_name: :create_trigger_name } }
        
        it "routes to default update trigger and create trigger with the specified name" do
          expect(subject).to eq([
            [:create_trigger_name,   :trigger, { event: :create }], 
            [:trg_mv_table_name_upd, :trigger, { event: :update }]
          ])
        end
      end

      describe "when update_trigger name is defined" do
        let(:options) { { as: :trigger, update_trigger_name: :update_trigger_name } }
        
        it "routes to default create trigger and update trigger with the specified name" do
          expect(subject).to eq([
            [:trg_mv_table_name_ins, :trigger, { event: :create }], 
            [:update_trigger_name,   :trigger, { event: :update }]
          ])
        end
      end
    end

    describe "when validation event == :save" do
       describe "when neither create_trigger_name nor update_trigger_name are not defined" do
        let(:options) { {as: :trigger} }
        
        it "routes to default update and insert trigger" do
          expect(subject).to eq([
            [:trg_mv_table_name_ins, :trigger, { event: :create }], 
            [:trg_mv_table_name_upd, :trigger, { event: :update }]
          ])
        end
      end

      describe "when create_trigger name is defined" do
        let(:options) { { as: :trigger, create_trigger_name: :create_trigger_name } }
        
        it "routes to default update trigger and create trigger with the specified name" do
          expect(subject).to eq([
            [:create_trigger_name,   :trigger, { event: :create }], 
            [:trg_mv_table_name_upd, :trigger, { event: :update }]
          ])
        end
      end

      describe "when update_trigger name is defined" do
        let(:options) { { as: :trigger, update_trigger_name: :update_trigger_name } }
        
        it "routes to default create trigger and update trigger with the specified name" do
          expect(subject).to eq([
            [:trg_mv_table_name_ins, :trigger, { event: :create }],
            [:update_trigger_name,   :trigger, { event: :update }]
          ])
        end
      end
    end

    describe "when validation event == :create" do
       describe "when neither create_trigger_name is not defined" do
        let(:options) { { as: :trigger, on: :create } }
        
        it "routes to default insert trigger" do
          expect(subject).to eq([
            [:trg_mv_table_name_ins, :trigger, { event: :create }]
          ])
        end
      end

      describe "when create_trigger name is defined" do
        let(:options) { { as: :trigger, create_trigger_name: :create_trigger_name, on: :create } }
        
        it "routes to create trigger with the specified name" do
          expect(subject).to eq([
            [:create_trigger_name, :trigger, { event: :create }]
          ])
        end
      end
    end

    describe "when validation event == :update" do
       describe "when update_trigger_name is not defined" do
        let(:options) { { as: :trigger, on: :update } }
        
        it "routes to default update trigger" do
          expect(subject).to eq([
            [:trg_mv_table_name_upd, :trigger, { event: :update }]
          ])
        end
      end

      describe "when update_trigger name is defined" do
        let(:options) { { as: :trigger, update_trigger_name: :update_trigger_name, on: :update } }
        
        it "routes to update trigger with the specified name" do
          expect(subject).to eq([
            [:update_trigger_name, :trigger, { event: :update }]
          ])
        end
      end
    end
  end
end