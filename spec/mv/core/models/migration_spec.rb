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

	describe '#add_validator' do
		subject(:add_validator) {
			migration.add_validator(table_name: :table_name, 
				                      column_name: :column_name, 
				                      validator_name: :length,
				                      options: { is: 5 })
		}

		it 'creates new validator' do
			expect{ subject }.to change(Mv::Core::Models::MigrationValidator, :count).from(0).to(1)
		end

		it 'sets validator version' do
			subject
			expect(Mv::Core::Models::MigrationValidator.first.version).to eq('20141118164617')
		end
	end

	describe 'validators' do
		subject(:validator) { migration.validators.collect(&:version) }

		describe 'with the same version' do
			before do
			  Mv::Core::Models::MigrationValidator.create(version: '20141118164617', 
			  																					  table_name: :table_name, 
			  																					  column_name: :column_name, 
			  																					  validator_name: :length, 
			  																					  options: { is: 5 })
			end

			it { is_expected.to eq(['20141118164617']) }
		end

		describe 'with earlier version' do
			before do
			  Mv::Core::Models::MigrationValidator.create(version: '19000101010001',
			  																					  table_name: :table_name, 
			  																					  column_name: :column_name, 
			  																					  validator_name: :length, 
			  																					  options: { is: 5 })
			end
		  
			it { is_expected.to eq(['19000101010001']) }
		end

		describe 'with later version' do
			before do
			  Mv::Core::Models::MigrationValidator.create(version: '2015101010001',
			  																					  table_name: :table_name, 
			  																					  column_name: :column_name, 
			  																					  validator_name: :length, 
			  																					  options: { is: 5 })
			end

			it { is_expected.to be_blank }
		end

		describe 'with overlapped version' do
			before do
			  Mv::Core::Models::MigrationValidator.create(version: '19000101010001',
			  																					  table_name: :table_name, 
			  																					  column_name: :column_name, 
			  																					  validator_name: :length, 
			  																					  options: { is: 5 })
			  Mv::Core::Models::MigrationValidator.create(version: '19000101010002',
			  																					  table_name: :table_name, 
			  																					  column_name: :column_name, 
			  																					  validator_name: :length, 
			  																					  options: { is: 6 })
			end

			it { is_expected.to eq(['19000101010002']) }
		end
	end

	describe "##set_version" do
		before { described_class.set_current('19000101010001') }

		subject { described_class.current }

		it { is_expected.to be_present }
		its(:version) { is_expected.to eq('19000101010001') }
	end
end