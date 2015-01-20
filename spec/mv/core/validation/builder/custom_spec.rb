require 'spec_helper'

require 'mv/core/validation/custom'
require 'mv/core/validation/builder/custom'

describe Mv::Core::Validation::Builder::Custom do
  def custom(opts = {})
    Mv::Core::Validation::Custom.new(:table_name, 
                                     :column_name,
                                     { message: 'some error message' }.merge(opts))
  end

  let(:builder_class) {
    Class.new(described_class) do
      protected

      def column_reference
        "NEW.#{column_name}" 
      end
    end
  }

  describe "#initialize" do
    subject { builder_class.new(custom) }

    its(:validation) { is_expected.to eq(custom) }
    its(:allow_nil) { is_expected.to eq(custom.allow_nil) }
    its(:allow_blank) { is_expected.to eq(custom.allow_blank) }
    its(:column_name) { is_expected.to eq(custom.column_name) }
  end

  describe "#conditions" do
    subject { builder_class.new(custom(opts)).conditions }

    describe "by default" do
      describe "when column_name provided" do
        let(:opts) { { statement: "{column_name} > 0" } }

        it { is_expected.to eq([{
          statement: "NEW.column_name IS NOT NULL AND (column_name > 0)", 
          message: 'some error message'
        }]) }
      end

      describe "when column_value provided" do
        let(:opts) { { statement: "{column_value} > 0"} }

        it { is_expected.to eq([{
          statement: "NEW.column_name IS NOT NULL AND (NEW.column_name > 0)", 
          message: 'some error message'
        }]) }
      end

      describe "when table_name provided" do
        let(:opts) { { statement: "{table_name}.{column_name} > 0"} }

        it { is_expected.to eq([{
          statement: "NEW.column_name IS NOT NULL AND (table_name.column_name > 0)", 
          message: 'some error message'
        }]) }
      end
    end

    describe "when nil is allowed" do
      let(:opts) { { statement: "{column_name} > 0", allow_nil: true } }

      it { is_expected.to eq([{
        statement: "(column_name > 0) OR NEW.column_name IS NULL", 
        message: 'some error message'
      }]) }
    end

    describe "when blank is allowed" do
      let(:opts) { { statement: "{column_name} > 0", allow_blank: true } }

      it { is_expected.to eq([{
        statement: "(column_name > 0) OR NEW.column_name IS NULL OR LENGTH(TRIM(NEW.column_name)) = 0", 
        message: 'some error message'
      }]) }
    end

    describe "when both blank and nil are allowed" do
      let(:opts) { { statement: "{column_name} > 0", allow_blank: true, allow_nil: true } }

      it { is_expected.to eq([{
        statement: "(column_name > 0) OR NEW.column_name IS NULL OR LENGTH(TRIM(NEW.column_name)) = 0", 
        message: 'some error message'
      }]) }
    end
  end
end
