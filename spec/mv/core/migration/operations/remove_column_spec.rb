require 'spec_helper'

require 'mv/core/migration/operations/remove_column'

describe Mv::Core::Migration::Operations::RemoveColumn do
  subject(:remove_column_operation) do
    described_class.new(:table_name, :column_name)
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
  end
  
end