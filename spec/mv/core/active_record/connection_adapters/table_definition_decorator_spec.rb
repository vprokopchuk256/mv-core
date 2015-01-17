require 'spec_helper'

describe Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator do
  let(:conn) { ::ActiveRecord::Base.connection }

  describe "#validates" do
    subject :create_table do
      conn.create_table :table_name, id: false do |t|
        t.string :column_name
        t.validates :column_name, length: { is: 5 }
      end
    end

    it "calls migration change_column method" do
      expect(Mv::Core::Migration::Base).to receive(:change_column).with(
        :table_name, :column_name, length: { is: 5 }
      ).at_least(:once)
      create_table
    end
  end

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