require 'spec_helper'

require 'mv/core/validation/presence'
require 'mv/core/validation/builder/presence'

describe Mv::Core::Validation::Builder::Presence do
  def presence(opts = {})
    Mv::Core::Validation::Presence.new(:table_name, 
                                        :column_name,
                                        opts) 
  end

  describe "#initialize" do
    subject { described_class.new(presence) }

    its(:validation) { is_expected.to eq(presence) }
    its(:allow_nil) { is_expected.to eq(presence.allow_nil) }
    its(:allow_blank) { is_expected.to eq(presence.allow_blank) }
    its(:column_name) { is_expected.to eq(presence.column_name) }
  end

  describe "#to_sql" do
    subject { described_class.new(presence(opts)).to_sql }

    describe "by default" do
      let(:opts) { {} }
       
      it { is_expected.to eq("column_name IS NOT NULL AND LENGTH(TRIM(column_name)) > 0") }
    end 

    describe "when nil is allowed" do
      let(:opts) { { allow_nil: true } }
      
      it { is_expected.to eq("column_name IS NULL OR LENGTH(TRIM(column_name)) > 0") }
    end

    describe "when blank is allowed" do
      let(:opts) { { allow_blank: true } }
      
      it { is_expected.to eq("column_name IS NOT NULL OR LENGTH(TRIM(column_name)) = 0") }
    end
  end
end