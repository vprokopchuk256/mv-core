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
    describe "by default" do
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
   			expect(conn.data_source_exists?(:table_name)).to be_truthy
   		end
    end

    describe "when simplification provided" do
      subject :create_table do
        conn.create_table :table_name, id: false do |t|
          t.column :column_name, :string, length: { is: 5 }
        end
      end

      it "calls migration add_column method" do
        expect(Mv::Core::Migration::Base).to receive(:add_column).with(
          :table_name, :column_name, length: { is: 5 }
        ).at_least(:once)
        create_table
      end

      it "should call original method" do
        create_table
        expect(conn.data_source_exists?(:table_name)).to be_truthy
      end
    end
 	end
end
