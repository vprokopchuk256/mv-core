require 'spec_helper'

require 'mv/core/validation/format'
require 'mv/core/validation/builder/format'

describe Mv::Core::Validation::Builder::Format do
  def format(opts = {})
    Mv::Core::Validation::Format.new(:table_name,
                                      :column_name,
                                      { with: /exp/, message: 'is not valid' }.merge(opts))
  end

  describe "#initalize" do
    subject { described_class.new(format) }

    its(:validation) { is_expected.to eq(format) }
    its(:with) { is_expected.to eq(format.with) }
    its(:allow_nil) { is_expected.to eq(format.allow_nil) }
    its(:allow_blank) { is_expected.to eq(format.allow_blank) }
    its(:column_name) { is_expected.to eq(format.column_name) }
    its(:message) { is_expected.to eq(format.full_message) }
  end

  describe "#conditions" do
    subject { described_class.new(format(opts)).conditions }

    describe "when regex passed" do
      let(:opts) { { with: /exp/ } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name REGEXP 'exp'",
        message: 'ColumnName is not valid'
      }]) }
    end

    describe "when string passed" do
      let(:opts) { { with: 'exp' } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name REGEXP 'exp'",
        message: 'ColumnName is not valid'
      }]) }
    end

    describe "when not supported type passed" do
      let(:opts) { { with: 1 } }

      it 'raises an error' do
        expect{ subject }.to raise_error(Mv::Core::Error)
      end
    end

    describe "when nil is allowed" do
      let(:opts) { { with: /exp/, allow_nil: true } }

      it { is_expected.to eq([{
        statement: "column_name REGEXP 'exp' OR column_name IS NULL",
        message: 'ColumnName is not valid'
      }]) }
    end

    describe "when blank is allowed" do
      let(:opts) { { with: /exp/, allow_blank: true } }

      it { is_expected.to eq([{
        statement: "column_name REGEXP 'exp' OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0",
        message: 'ColumnName is not valid'
      }]) }
    end

    describe "when blank and nill are both allowed" do
      let(:opts) { { with: /exp/, allow_blank: true, allow_nil: true } }

      it { is_expected.to eq([{
        statement: "column_name REGEXP 'exp' OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0",
        message: 'ColumnName is not valid'
      }]) }
    end
  end
end

