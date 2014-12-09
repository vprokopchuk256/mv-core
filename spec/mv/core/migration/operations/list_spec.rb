require 'spec_helper'

require 'mv/core/migration/operations/list'

describe Mv::Core::Migration::Operations::List do
  subject(:list) { described_class.new }

  describe "initilize" do
    its(:operations) { is_expected.to eq([]) }
  end

  describe "execute" do
    it "calls execute on all operations list" do
      operation = double 
      list.add_operation(operation)

      expect(operation).to receive(:execute).once
      list.execute
    end
    
  end
  
end