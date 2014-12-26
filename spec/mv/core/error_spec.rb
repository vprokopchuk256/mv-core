require 'spec_helper'

require 'mv/core/error'

describe Mv::Core::Error do
  describe "#initialization" do
    describe "default" do
      subject(:error) do 
        described_class.new()
      end
      
      its(:message) { is_expected.to be_blank }
    end
    describe "full" do
      subject(:error) do 
        described_class.new(table_name: :table_name, 
                            column_name: :column_name, 
                            validation_type: :uniqueness, 
                            options: { as: :trigger}, 
                            error: "Some error happened") 
      end

      its(:table_name) { is_expected.to eq(:table_name) }
      its(:column_name) { is_expected.to eq(:column_name) }
      its(:validation_type) { is_expected.to eq(:uniqueness) }
      its(:options) { is_expected.to eq('as' => :trigger)}
      its(:message) { 
       is_expected.to eq(
        "table: 'table_name', column: 'column_name', validator: 'uniqueness', options: '{\"as\"=>:trigger}', error: 'Some error happened'"
       )
      }
    end
  end 
  
end