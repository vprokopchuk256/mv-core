require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/check'
require 'mv/core/validation/inclusion'
require 'mv/core/validation/exclusion'

describe Mv::Core::Constraint::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:check_description) { Mv::Core::Constraint::Description.new(:chk_mv_table_name, :check)}

  subject(:check) { described_class.new(check_description) }

  describe "#initialize" do
    its(:description) { is_expected.to eq(check_description) }
    its(:validations) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#<=>" do
    let(:inclusion) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2], as: :check) }
    let(:exclusion) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [0, 3], as: :check) }

    before do
      check.validations << inclusion
      check.validations << exclusion
    end

    it { is_expected.to eq(check) }

    describe "when description is different" do
      let(:other_check_description) { Mv::Core::Constraint::Description.new(:chk_mv_table_name_1, :check) }
      let(:other_check) { described_class.new(other_check_description) }

      before do
        other_check.validations << inclusion
        other_check.validations << exclusion
      end
      
      it { is_expected.not_to eq(other_check) }
    end

    describe "when validations list contains different elements" do
      let(:other_check) { described_class.new(check_description) }

      before do
        other_check.validations << inclusion
      end
      
      it { is_expected.not_to eq(other_check) }
    end

    describe "when validations list sorted differently" do
      let(:other_check) { described_class.new(check_description) }

      before do
        other_check.validations << exclusion
        other_check.validations << inclusion
      end
      
      it { is_expected.to eq(other_check) }
    end

    describe "when description and validations list are the same" do
      let(:other_check) { described_class.new(check_description) }

      before do
        other_check.validations << inclusion
        other_check.validations << exclusion
      end
      
      it { is_expected.to eq(other_check) }
    end
  end
end