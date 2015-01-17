require 'spec_helper'

describe Mv::Core::ActiveRecord::ConnectionAdapters::TableDecorator do
  let(:conn) { ::ActiveRecord::Base.connection }

  before do
    conn.class.send(
      :prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
    )

    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#validates" do
    before do
      conn.create_table :table_name, id: false do |t|
        t.string :column_name
      end
    end

    subject :change_table do
      conn.change_table :table_name do |t|
        t.validates :column_name, length: { is: 5 }
      end
    end

    it "calls migration change_column method" do
      expect(Mv::Core::Migration::Base).to receive(:change_column).with(
        :table_name, :column_name, length: { is: 5 }
      ).at_least(:once)
      change_table
    end
  end
end