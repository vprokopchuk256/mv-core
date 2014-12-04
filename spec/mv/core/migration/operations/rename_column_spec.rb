require 'spec_helper'

require 'mv/core/migration/operations/rename_column'

describe Mv::Core::Migration::Operations::RenameColumn do
  subject(:rename_column_operation) do
    described_class.new('20141118164617', :table_name, :old_column_name, :new_column_name)
  end

  describe "#initialize" do
    its(:version) { is_expected.to eq('20141118164617') }
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:old_column_name) { is_expected.to eq(:old_column_name) }
    its(:new_column_name) { is_expected.to eq(:new_column_name) }
  end
  
end