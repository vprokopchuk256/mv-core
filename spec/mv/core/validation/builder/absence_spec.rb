require 'spec_helper'

require 'mv/core/validation/absence'
require 'mv/core/validation/builder/absence'

describe Mv::Core::Validation::Builder::Absence do
  def absence(opts = {})
    Mv::Core::Validation::Absence.new(:table_name, 
                                      :column_name,
                                      { message: 'should be empty' }.merge(opts))
  end

  describe "#initialize" do
    subject { described_class.new(absence) }

    its(:validation) { is_expected.to eq(absence) }
    its(:allow_nil) { is_expected.to eq(absence.allow_nil) }
    its(:allow_blank) { is_expected.to eq(absence.allow_blank) }
    its(:column_name) { is_expected.to eq(absence.column_name) }
  end

  describe "#conditions" do
    subject { described_class.new(absence(opts)).conditions }

    describe "by default" do
      let(:opts) { {} }
       
      it { is_expected.to eq([{
        statement: "column_name IS NULL OR LENGTH(TRIM(column_name)) = 0", 
        message: 'ColumnName should be empty'
      }]) }
    end 

    describe "when nil is denied" do
      let(:opts) { { allow_nil: false } }
      
      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND LENGTH(TRIM(column_name)) = 0", 
        message: 'ColumnName should be empty'
      }]) }
    end

    describe "when blank is denied" do
      let(:opts) { { allow_blank: false } }
      
      it { is_expected.to eq([{
        statement: "column_name IS NULL AND LENGTH(TRIM(column_name)) > 0", 
        message: 'ColumnName should be empty'
      }]) }
    end
  end
end