require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router'

Description = Mv::Core::Constraint::Description

describe Mv::Core::Router do
  let(:migration_validator) { create(:migration_validator) }

  subject(:router) { described_class }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    let(:uniqueness) { 
      Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, options) 
    }

    subject { described_class.route(uniqueness) }

    describe "when :as == :index" do
      let(:options) { { as: :index } }

      it { is_expected.to eq([Description.new(uniqueness.index_name, :index)]) }
    end

    # describe "when :as == :check" do
    #   let(:options) { { as: :check } }

    #   it { is_expected.to eq([Description.new(uniqueness.check_name, :check)]) }
    # end

    describe "when :as == :trigger" do
      describe "when :on == :save" do
        let(:options) { { as: :trigger, on: :save } }

        it { is_expected.to match_array([
          Description.new(uniqueness.update_trigger_name, :trigger, event: :update), 
          Description.new(uniqueness.create_trigger_name, :trigger, event: :create)
        ]) }
      end

      describe "when :on == :create" do
        let(:options) { { as: :trigger, on: :create } }

        it { is_expected.to eq([Description.new(uniqueness.create_trigger_name, :trigger, event: :create)]) }
      end

      describe "when :on == :update" do
        let(:options) { { as: :trigger, on: :update } }
        
        it { is_expected.to eq([Description.new(uniqueness.update_trigger_name, :trigger, event: :update)]) }
      end
    end
  end
end   
