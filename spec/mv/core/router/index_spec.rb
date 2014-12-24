require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/index'

describe Mv::Core::Router::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    let(:uniqueness) { Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                            :column_name,
                                                            as: :index) }

    subject { described_class.new.route(uniqueness) }

    it { is_expected.to eq([
      Mv::Core::Constraint::Description.new(uniqueness.index_name, :index)
    ]) }
  end
end