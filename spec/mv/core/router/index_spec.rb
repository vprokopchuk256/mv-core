require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/index'

describe Mv::Core::Router::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    subject { described_class.new.route(migration_validator) }

    describe "when index name is not defined explicitly" do
      let(:migration_validator) { create(:migration_validator, options: { as: :index })}

      it "should route to default index name" do
        expect(subject).to eq(idx_mv_table_name_column_name_uniq: { type: :index } )
      end
    end

    describe "when index name is not explicitly" do
      let(:migration_validator) { create(:migration_validator, options: { as: :index, index_name: :index_name })}

      it "should route to default index name" do
        expect(subject).to eq(index_name: { type: :index })
      end
    end
  end 
end