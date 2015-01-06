require 'spec_helper'

require 'mv/core/validation/presence'
require 'mv/core/validation/builder/presence'

describe Mv::Core::Validation::Builder::Presence do
  def presence(opts = {})
    Mv::Core::Validation::Presence.new(:table_name, 
                                        :column_name,
                                        { message: 'some error message' }.merge(opts))
  end

  describe "#initialize" do
    subject { described_class.new(presence) }

    its(:validation) { is_expected.to eq(presence) }
    its(:allow_nil) { is_expected.to eq(presence.allow_nil) }
    its(:allow_blank) { is_expected.to eq(presence.allow_blank) }
    its(:column_name) { is_expected.to eq(presence.column_name) }
  end

  describe "#conditions" do
    subject { described_class.new(presence(opts)).conditions }

    describe "by default" do
      let(:opts) { {} }
       
      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND LENGTH(TRIM(column_name)) > 0", 
        message: 'some error message'
      }]) }
    end 

    describe "when nil is allowed" do
      let(:opts) { { allow_nil: true } }
      
      it { is_expected.to eq([{
        statement: "column_name IS NULL OR LENGTH(TRIM(column_name)) > 0", 
        message: 'some error message'
      }]) }
    end

    describe "when blank is allowed" do
      let(:opts) { { allow_blank: true } }
      
      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL OR LENGTH(TRIM(column_name)) = 0", 
        message: 'some error message'
      }]) }
    end
  end
end