require 'spec_helper'

require 'mv/core/validation/uniqueness'
require 'mv/core/validation/builder/uniqueness'

describe Mv::Core::Validation::Builder::Uniqueness do
  def uniqueness(opts = {})
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name,
                                         opts) 
  end

  describe "#initialize" do
    subject { described_class.new(uniqueness) }

    its(:validation) { is_expected.to eq(uniqueness) }
    its(:allow_nil) { is_expected.to eq(uniqueness.allow_nil) }
    its(:allow_blank) { is_expected.to eq(uniqueness.allow_blank) }
    its(:column_name) { is_expected.to eq(uniqueness.column_name) }
    its(:table_name) { is_expected.to eq(uniqueness.table_name) }
  end

  describe "#to_sql" do
    let(:uniqueness_builder) do
      Class.new(described_class) do
        def column_reference
          :db_name
        end
      end
    end
    subject { uniqueness_builder.new(uniqueness(opts)).to_sql }

    describe "by default" do
      let(:opts) { {} }

      it { is_expected.to eq("NOT EXISTS(SELECT column_name 
                                           FROM table_name 
                                          WHERE db_name = column_name)".squish)}
    end

    describe "when nil is allowed" do
      let(:opts) { {allow_nil: true} }
      
      it { is_expected.to eq("NOT EXISTS(SELECT column_name 
                                           FROM table_name 
                                          WHERE db_name = column_name)
                                  OR db_name IS NULL".squish)}
    end

    describe "when blank is allowed" do
      let(:opts) { {allow_blank: true} }

      it { is_expected.to eq("NOT EXISTS(SELECT column_name 
                                           FROM table_name 
                                          WHERE db_name = column_name)
                                  OR db_name IS NULL
                                  OR LENGTH(TRIM(db_name)) = 0".squish)}
      
    end

    describe "when both blank & nil are allowed" do
      let(:opts) { {allow_blank: true, allow_nil: true} }
      
      it { is_expected.to eq("NOT EXISTS(SELECT column_name 
                                           FROM table_name 
                                          WHERE db_name = column_name)
                                  OR db_name IS NULL
                                  OR LENGTH(TRIM(db_name)) = 0".squish)}
    end
  end
end