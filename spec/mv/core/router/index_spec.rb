require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/index'

describe Mv::Core::Router::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    subject { described_class.new.route(:table_name, :column_name, :uniqueness, options) }

    describe "when index name is not defined explicitly" do
      let(:options) { { as: :index } }

      it "routes to default index name" do
        expect(subject).to eq([
          Mv::Core::Constraint::Description.new(:idx_mv_table_name_column_name_uniq, :index)
        ])
      end
    end

    describe "when index name is not explicitly" do
      let(:options) { { as: :index, index_name: :index_name } }

      it "should route to default index name" do
        expect(subject).to eq([
          Mv::Core::Constraint::Description.new(:index_name, :index)
        ])
      end
    end
  end 
end