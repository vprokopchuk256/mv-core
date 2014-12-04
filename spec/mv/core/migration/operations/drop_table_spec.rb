require 'spec_helper'

require 'mv/core/migration/operations/drop_table'

describe Mv::Core::Migration::Operations::DropTable do
  subject(:drop_column_operation) do
    described_class.new('20141118164617', :table_name)
  end

  describe "#initialize" do
    its(:version) { is_expected.to eq('20141118164617') }
    its(:table_name) { is_expected.to eq(:table_name) }
  end
end