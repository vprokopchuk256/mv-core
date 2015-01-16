require 'spec_helper'

require 'mv/core/migration/base'
require 'mv/core/active_record/connection_adapters/abstract_adapter_decorator'

describe Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator do
  before do
    ::ActiveRecord::Base.connection.class.send(:prepend, described_class)
  end

  let(:conn) { ::ActiveRecord::Base.connection }

  describe "#add_column" do
    before do
      conn.create_table :table_name do |t|
        t.string :col_name
      end
    end

    subject :add_column do
      conn.add_column :table_name, :column_name, :string, 
                      validates: { length: { is: 5 } }
    end

    it "calls migration add_column method" do
      expect(Mv::Core::Migration::Base.current).to receive(:add_column).with(
        :table_name, :column_name, length: { is: 5}
      )
      add_column
    end

    it "calls original method" do
      add_column
      expect(conn.column_exists?(:table_name, :column_name)).to be_truthy
    end
  end 

  describe "#remove_column" do
    before do
      conn.create_table :table_name do |t|
        t.string :col_name
        t.string :column_name
        t.string :column_name_1
      end
    end
    
    subject :remove_column do
      conn.remove_column :table_name, :column_name, :string, {}
    end

    it "calls migration remove_column method" do
      expect(Mv::Core::Migration::Base.current).to receive(:remove_column).with(
        :table_name, :column_name
      )
      remove_column
    end

    it "calls original method" do
      remove_column
      expect(conn.column_exists?(:table_name, :column_name)).to be_falsey
    end
  end

  describe "#rename_column" do
    before do
      conn.create_table :table_name do |t|
        t.string :col_name
      end
    end
    
    subject :rename_column do
      conn.rename_column :table_name, :col_name, :column_name
    end

    it "calls migration rename_column method" do
      expect(Mv::Core::Migration::Base.current).to receive(:rename_column).with(
        :table_name, :col_name, :column_name
      )
      rename_column
    end

    it "call original method" do
      rename_column
      expect(conn.column_exists?(:table_name, :column_name)).to be_truthy
    end
  end

  describe "#validates" do
    before do
      td = conn.create_table :table_name do |t|
        t.string :column_name
      end
    end

    subject :validates do
      conn.validates :table_name, :column_name, length: { is: 5 } 
    end

    it "calls migration change_column method" do
      expect(Mv::Core::Migration::Base.current).to receive(:change_column).with(
        :table_name, :column_name, length: { is: 5 } 
      )
      validates
    end
  end

  describe "#change_column" do
    before do
      td = conn.create_table :table_name do |t|
        t.string :column_name
      end
    end

    subject :change_column do
      conn.change_column :table_name, :column_name, :integer, 
                         validates: { length: { is: 5 } }
    end

    it "calls migratin change_column method" do
      expect(Mv::Core::Migration::Base.current).to receive(:change_column).with(
        :table_name, :column_name, length: { is: 5 } 
      )
      change_column
    end

    it "calls original method" do
      change_column

      cls = Class.new(::ActiveRecord::Base) do
        self.table_name = "table_name"
      end

      expect(cls.columns_hash['column_name'].type).to eq(:integer)
    end
  end

  describe "#rename_table" do
    before do
      td = conn.create_table :table_name do |t|
        t.string :column_name
      end
    end

    subject :rename_table do
      conn.rename_table :table_name, :new_table_name
    end

    it "calls migration rename_table method" do
      expect(Mv::Core::Migration::Base.current).to receive(:rename_table).with(
        :table_name, :new_table_name
      )
      rename_table
    end

    it "calls original rename_table method" do
      rename_table

      expect(conn.table_exists?(:new_table_name)).to be_truthy
    end
  end

  describe "#drop_table" do
    before do
      td = conn.create_table :table_name do |t|
        t.string :column_name
      end
    end

    describe "without params" do
      subject :drop_table do
        conn.drop_table :table_name
      end

      it "calls migration drop_table method" do
        expect(Mv::Core::Migration::Base.current).to receive(:drop_table).with(
          :table_name
        )
        drop_table
      end

      it "calls original drop_table method" do
        drop_table

        expect(conn.table_exists?(:table_name)).to be_falsey
      end
    end

    describe "with params" do
      subject :drop_table do
        conn.drop_table :table_name, id: false
      end

      it "calls migration drop_table method" do
        expect(Mv::Core::Migration::Base.current).to receive(:drop_table).with(
          :table_name
        )
        drop_table
      end

      it "calls original drop_table method" do
        drop_table

        expect(conn.table_exists?(:table_name)).to be_falsey
      end
    end
  end
end