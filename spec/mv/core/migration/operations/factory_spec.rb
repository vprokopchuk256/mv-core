require 'spec_helper'

require 'mv/core/migration/operations/factory'
require 'mv/core/migration/operations/add_column'

describe Mv::Core::Migration::Operations::Factory do
  subject(:operations_factory) { described_class.new }

  describe "#create_operation" do
    subject { operations_factory.create_operation(:add_column, :table_name, :column_name, length: { id: 5 }) }

    it "should create AddColumn operation instance" do
      expect(Mv::Core::Migration::Operations::AddColumn).to receive(:new).with(
        :table_name, :column_name, length: { id: 5 }
      )

      subject
    end

    it "should return newly created operations" do
      expect(subject).to be_kind_of(Mv::Core::Migration::Operations::AddColumn)
    end
  end
end

