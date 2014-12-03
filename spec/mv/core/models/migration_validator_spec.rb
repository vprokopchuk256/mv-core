require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/models/migration_validator'

describe Mv::Core::Models::MigrationValidator do
	subject(:migration_validator) { 
		described_class.create(version: '20141118164617',
												table_name: :table_name, 
			                  column_name: :column_name, 
			                  validator_name: :validator_name)}
	before do
	  Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
	end

	describe "db" do
		it { is_expected.to have_db_column(:version).with_options(null: false) }
		it { is_expected.to have_db_column(:table_name).with_options(null: false) }
		it { is_expected.to have_db_column(:column_name).with_options(null: false) }
		it { is_expected.to have_db_column(:validator_name).with_options(null: false) }
		it { is_expected.to have_db_column(:options) }
	end

	describe "validations" do
	  it { is_expected.to validate_presence_of(:table_name) }
	  it { is_expected.to validate_presence_of(:column_name) }
	  it { is_expected.to validate_presence_of(:validator_name) }
	end

	describe "options" do
		describe "when empty" do
			before do
				migration_validator.update_attributes(options: nil)
			end

			it "initialized by empty hash by default" do
				expect(migration_validator.options).to eq({})
			end
		end
	end

	describe "scopes" do
		describe "for_version" do
			describe "invalid" do
				subject { described_class.for_version('20131118164617') }

				it { is_expected.not_to include(migration_validator) }
			  
			end

			describe "valid" do
				subject { described_class.for_version('20141118164617') }
			  
				it { is_expected.to include(migration_validator) }
			end
		end
	end
end