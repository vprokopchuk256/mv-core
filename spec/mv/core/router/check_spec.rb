require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/check'

describe Mv::Core::Router::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end
  
  describe "#route" do
    subject { described_class.new.route(:table_name, :column_name, :uniqueness, options) }

    describe "when check name is not defined explicitly" do
      let(:options) { { as: :check } }

      it "routes to default check name" do
        expect(subject).to eq([[:chk_mv_table_name, :check, {}]])
      end
    end

    describe "when check name is not explicitly" do
      let(:options) { { as: :check, check_name: :check_name } }

      it "should route to default check name" do
        expect(subject).to eq([[:check_name, :check, {}]])
      end
    end
  end 
end