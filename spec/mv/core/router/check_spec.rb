require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/check'
require 'mv/core/validation/uniqueness'

describe Mv::Core::Router::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  describe "#route" do
    let(:uniqueness) { Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                            :column_name,
                                                            as: :check) }

    subject { described_class.new.route(uniqueness) }

    it { is_expected.to eq([
      Mv::Core::Constraint::Description.new(uniqueness.check_name, :check)
    ]) }
  end
end