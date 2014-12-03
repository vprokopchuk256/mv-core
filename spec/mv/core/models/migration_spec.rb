require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/models/migration_validator'
require 'mv/core/models/migration' 

describe Mv::Core::Models::Migration do
	before do
	  Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
	end

	subject(:migration) { described_class.new('20141118164617') }

	describe '#initialize' do
		describe '#version' do
			subject{ migration.version }

			it { is_expected.to eq('20141118164617') }
		end
	end

	describe "##set_version" do
		before { described_class.set_current('19000101010001') }

		subject { described_class.current }

		it { is_expected.to be_present }
		its(:version) { is_expected.to eq('19000101010001') }
	end
end