require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/router/base'

describe Mv::Core::Router::Base do
  let(:migration_validator) { create(:migration_validator) }

  subject(:router) { described_class }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    it "redirects to specific router" do
      trigger_route = double
      allow(trigger_route).to receive(:route).with(migration_validator).and_return( trg_table_name_update: :trigger )

      allow_any_instance_of(Mv::Core::Router::Factory).to receive(:create_router).with(migration_validator).and_return(trigger_route)

      expect(router.route(migration_validator)).to eq(trg_table_name_update: :trigger)
    end
  end
  
end