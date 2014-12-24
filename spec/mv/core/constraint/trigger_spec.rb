require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/trigger'
require 'mv/core/error'

describe Mv::Core::Constraint::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:trigger_description) { Mv::Core::Constraint::Description.new(:update_trigger_name, 
                                                                    :trigger, 
                                                                    { event: :update })}

  subject(:trigger) { described_class.new(trigger_description) }

  describe "#initialize" do
    its(:description) { is_expected.to eq(trigger_description) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end
end