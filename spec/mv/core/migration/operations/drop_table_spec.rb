require 'spec_helper'

require 'mv/core/migration/operations/drop_table'

describe Mv::Core::Migration::Operations::DropTable do
  subject(:drop_column_operation) do
    described_class.new(:table_name)
  end

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
  end
end