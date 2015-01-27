require 'spec_helper'

require 'mv/core/validation/length'
require 'mv/core/validation/builder/length'

describe Mv::Core::Validation::Builder::Length do
  def length(opts = {})
    Mv::Core::Validation::Length.new(:table_name, 
                                     :column_name,
                                     { message: 'has invalid length' }.merge(opts))
  end

  describe "#initalize" do
    let(:validation) { length(is: 5) }
    subject { described_class.new(validation) }

    its(:validation) { is_expected.to eq(validation) }    
    its(:in) { is_expected.to eq(validation.in) }
    its(:within) { is_expected.to eq(validation.within) }
    its(:is) { is_expected.to eq(validation.is) }
    its(:maximum) { is_expected.to eq(validation.maximum) }
    its(:minimum) { is_expected.to eq(validation.minimum) }
    its(:allow_nil) { is_expected.to eq(validation.allow_nil) }
    its(:allow_blank) { is_expected.to eq(validation.allow_blank) }
    its(:column_name) { is_expected.to eq(validation.column_name) }
    its(:message) { is_expected.to eq(validation.full_message) }
    its(:too_short) { is_expected.to eq(validation.full_too_short) }
    its(:too_long) { is_expected.to eq(validation.full_too_long) }
  end

  describe "conditions" do
    subject { described_class.new(length(opts)).conditions }


    describe "when :in is defined" do
      describe "as array" do
        let(:opts) { { in: [1, 3] } }

        it { is_expected.to eq([{
          statement: 'column_name IS NOT NULL AND LENGTH(column_name) IN (1, 3)', 
          message: 'ColumnName has invalid length'
        }]) }
      end

      describe "as range" do
        let(:opts) { { in: 1..3 } }

        it { is_expected.to eq([{
          statement: 'column_name IS NOT NULL AND LENGTH(column_name) BETWEEN 1 AND 3', 
          message: 'ColumnName has invalid length'
        }]) }
      end
    end

    describe "when :within is defined" do
      describe "as array" do
        let(:opts) { { within: [1, 3] } }

        it { is_expected.to eq([{
          statement: 'column_name IS NOT NULL AND LENGTH(column_name) IN (1, 3)', 
          message: 'ColumnName has invalid length'
        }]) }
      end

      describe "as range" do
        let(:opts) { { within: 1..3 } }

        it { is_expected.to eq([{
          statement: 'column_name IS NOT NULL AND LENGTH(column_name) BETWEEN 1 AND 3', 
          message: 'ColumnName has invalid length'
        }]) }
      end
    end

    describe "when :is is defined" do
      let(:opts) { { is: 1 } }

      it { is_expected.to eq([{
        statement: 'column_name IS NOT NULL AND LENGTH(column_name) = 1', 
        message: 'ColumnName has invalid length'
      }]) }
    end

    describe "when :maximum is defined" do
      let(:opts) { { maximum: 3, too_long: 'is longer than expected' } }

      it { is_expected.to eq([{
        statement: 'column_name IS NOT NULL AND LENGTH(column_name) <= 3', 
        message: 'ColumnName is longer than expected'
      }]) }
    end

    describe "when :minimum is defined" do
      let(:opts) { { minimum: 1, too_short: 'is shorter than expected' } }

      it { is_expected.to eq([{
        statement: 'column_name IS NOT NULL AND LENGTH(column_name) >= 1', 
        message: 'ColumnName is shorter than expected'
      }]) }
    end

    describe "when both :maximum & :minimum are defined" do
      # it { is_expected.to eq('LENGTH(column_name) BETWEEN 1 AND 3') }
      describe "and too long and too short messages are the same" do
        let(:opts) { { minimum: 1, maximum: 3, too_long: 'is longer than expected', too_short: 'is shorter than expected' } }

        it { is_expected.to match_array([
          { statement: 'column_name IS NOT NULL AND LENGTH(column_name) >= 1', 
            message: 'ColumnName is shorter than expected' },
          { statement: 'column_name IS NOT NULL AND LENGTH(column_name) <= 3', 
            message: 'ColumnName is longer than expected' }
        ]) }
        
      end

      describe "and too long and too short messages are different" do
        let(:opts) { { minimum: 1, maximum: 3, too_long: 'has invalid length', too_short: 'has invalid length' } }
        
        it { is_expected.to eq([{
          statement: 'column_name IS NOT NULL AND LENGTH(column_name) BETWEEN 1 AND 3', 
          message: 'ColumnName has invalid length'
        }]) }
      end
    end

    describe "when nil is allowed" do
      let(:opts) { { is: 1, allow_nil: true } }


      it { is_expected.to eq([{
        statement: 'LENGTH(column_name) = 1 OR column_name IS NULL', 
        message: 'ColumnName has invalid length'
      }]) }
    end

    describe "when blank is allowed" do
      let(:opts) { { is: 1, allow_blank: true } }

      it { is_expected.to eq([{
        statement: 'LENGTH(column_name) = 1 OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0', 
        message: 'ColumnName has invalid length'
      }]) }
    end

    describe "when both nil & blank are allowed" do
      let(:opts) { { is: 1, allow_nil: true, allow_blank: true } }

      it { is_expected.to eq([{
        statement: 'LENGTH(column_name) = 1 OR column_name IS NULL OR LENGTH(TRIM(column_name)) = 0', 
        message: 'ColumnName has invalid length'
      }]) }
    end
  end
end