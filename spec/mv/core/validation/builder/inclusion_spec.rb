require 'spec_helper'

require 'mv/core/validation/inclusion'
require 'mv/core/validation/builder/inclusion'

describe Mv::Core::Validation::Builder::Inclusion do
  def inclusion(opts = {})
    Mv::Core::Validation::Inclusion.new(:table_name,
                                        :column_name,
                                        { in: [1, 5], message: 'is included'}.merge(opts))
  end

  describe "#initalize" do
    subject { described_class.new(inclusion) }

    its(:validation) { is_expected.to eq(inclusion) }
    its(:in) { is_expected.to eq(inclusion.in) }
    its(:allow_nil) { is_expected.to eq(inclusion.allow_nil) }
    its(:allow_blank) { is_expected.to eq(inclusion.allow_blank) }
    its(:column_name) { is_expected.to eq(inclusion.column_name) }
    its(:message) { is_expected.to eq(inclusion.full_message) }
  end

  describe "#conditions" do
    subject { described_class.new(inclusion(opts)).conditions }

    describe "when integers array passed" do
      let(:opts) { { in: [1, 5], message: 'is included' } }

      it { is_expected.to eq([{
        statement: 'column_name IS NOT NULL AND column_name IN (1, 5)',
        message: 'column_name is included'
      }]) }
    end

    describe "when range passed" do
      let(:opts) { { in: 1..3 } }

      it { is_expected.to eq([{
        statement: 'column_name IS NOT NULL AND column_name BETWEEN 1 AND 3',
        message: 'column_name is included'
      }]) }
    end

    describe "when string range passed" do
      let(:opts) { { in: 'a'..'c' } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name BETWEEN 'a' AND 'c'",
        message: 'column_name is included'
      }]) }
    end

    describe "when strings array passed" do
      let(:opts) { {in: ['a', 'c']} }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name IN ('a', 'c')",
        message: 'column_name is included'
      }]) }
    end

    describe "when floats array passed" do
      let(:opts) { {in: [1.5, 1.8]} }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name IN (1.5, 1.8)",
        message: 'column_name is included'
      }]) }
    end

    describe "when not supported types array passed" do
      let(:opts) { {in: [{}, {}]} }

      it 'raises an error' do
        expect{ subject }.to raise_error(Mv::Core::Error)
      end
    end

    describe "when nil is allowed" do
      let(:opts) { { in: [1, 5], allow_nil: true } }

      it { is_expected.to eq([{
        statement: 'column_name IN (1, 5) OR column_name IS NULL',
        message: 'column_name is included'
      }]) }
    end

    describe "when blank is allowed" do
      let(:opts) { { in: [1, 5], allow_blank: true } }

      it { is_expected.to eq([{
        statement: 'column_name IN (1, 5) OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0',
        message: 'column_name is included'
      }]) }
    end

    describe "when blank and nill are both allowed" do
      let(:opts) { { in: [1, 5], allow_blank: true, allow_nil: true } }

      it { is_expected.to eq([{
        statement: 'column_name IN (1, 5) OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0',
        message: 'column_name is included'
      }]) }
    end
  end
end
