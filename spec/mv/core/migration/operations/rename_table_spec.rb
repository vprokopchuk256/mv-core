require 'spec_helper'

require 'mv/core/migration/operations/rename_table'

describe Mv::Core::Migration::Operations::RenameTable do
  subject(:rename_table_operation) do
    described_class.new(:table_name, :new_table_name)
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:new_table_name) { is_expected.to eq(:new_table_name) }
  end
end