require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'

describe Mv::Core::Constraint::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:index_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :index) }

  subject(:index) { described_class.new(index_description) }

  describe "#initialize" do
    its(:options) { is_expected.to eq({}) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
    its(:validators) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end
end