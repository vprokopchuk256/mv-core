require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/trigger'
require 'mv/core/constraint/builder/trigger'

describe Mv::Core::Constraint::Builder::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
  end

  let(:trigger_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :trigger) }
  let(:trigger_constraint) { Mv::Core::Constraint::Trigger.new(trigger_description) }
  let(:uniqueness) { 
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name, 
                                         as: :trigger, 
                                         update_trigger_name: :trg_mv_table_name) 
  }

  before do
    trigger_constraint.validations << uniqueness
  end

  subject(:trigger_builder) { described_class.new(trigger_constraint) }

  describe "#initialization" do
    its(:constraint) { is_expected.to eq(trigger_constraint) }
  end
end