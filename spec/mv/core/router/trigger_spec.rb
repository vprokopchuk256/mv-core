require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/trigger'
require 'mv/core/validation/uniqueness'

describe Mv::Core::Router::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    let(:uniqueness) { Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                            :column_name,
                                                            as: :trigger,
                                                            on: on) }

    subject { described_class.new.route(uniqueness) }

    describe "when :on == :save" do
      let(:on) { :save }

      it { is_expected.to match_array([
        Mv::Core::Constraint::Description.new(uniqueness.update_trigger_name, :trigger, event: :update), 
        Mv::Core::Constraint::Description.new(uniqueness.create_trigger_name, :trigger, event: :create)
      ]) }
    end

    describe "when :on == :create" do
      let(:on) { :create }

      it { is_expected.to eq([
        Mv::Core::Constraint::Description.new(uniqueness.create_trigger_name, :trigger, event: :create)
      ]) }
    end

    describe "when :on == :update" do
      let(:on) { :update }
      
      it { is_expected.to eq([
        Mv::Core::Constraint::Description.new(uniqueness.update_trigger_name, :trigger, event: :update)
      ]) }
    end
  end
end