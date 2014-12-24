require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/check'
require 'mv/core/error'

describe Mv::Core::Constraint::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:check_description) { Mv::Core::Constraint::Description.new(:chk_mv_table_name, :check)}

  subject(:check) { described_class.new(check_description) }

  describe "#initialize" do
    its(:description) { is_expected.to eq(check_description) }
    its(:validations) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end
end