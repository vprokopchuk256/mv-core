
require 'spec_helper'

require 'mv/core/migration/base'
require 'mv/core/active_record/connection_adapters/table_definition_decorator.rb'
require 'mv/core/services/create_migration_validators_table'

describe Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator do
  before do
    ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:prepend, described_class)
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Migration::Base.set_current('20141118164617')
  end

  let(:conn) { ::ActiveRecord::Base.connection }

 	describe "#column" do
 		subject :create_table do
 			conn.create_table :table_name, id: false do |t|
 				t.string :column_name, validates: { length: { is: 5 } }
 			end
 		end

    it "calls migration add_column method" do
      expect(Mv::Core::Migration::Base).to receive(:add_column).with(
        :table_name, :column_name, length: { is: 5 }
      ).at_least(:once)
      create_table
    end

 		it "should call original methos" do
 			create_table
 			expect(conn.table_exists?(:table_name)).to be_truthy
 		end
 	   
 	end 
end