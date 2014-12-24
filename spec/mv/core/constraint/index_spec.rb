require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'

describe Mv::Core::Constraint::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  let(:index_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :index) }

  subject(:index) { described_class.new(index_description) }

  describe "#initialize" do
    its(:options) { is_expected.to eq({}) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
    its(:validations) { is_expected.to eq([]) }
  end

  describe "#constraint interface" do
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
  end

  describe "#<=>" do
    let(:inclusion) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2], as: :index) }
    let(:exclusion) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [0, 3], as: :index) }

    before do
      index.validations << inclusion
      index.validations << exclusion
    end

    it { is_expected.to eq(index) }

    describe "when description is different" do
      let(:other_index_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name_1, :index) }
      let(:other_index) { described_class.new(other_index_description) }

      before do
        other_index.validations << inclusion
        other_index.validations << exclusion
      end
      
      it { is_expected.not_to eq(other_index) }
    end

    describe "when validations list contains different elements" do
      let(:other_index) { described_class.new(index_description) }

      before do
        other_index.validations << inclusion
      end
      
      it { is_expected.not_to eq(other_index) }
    end

    describe "when validations list sorted differently" do
      let(:other_index) { described_class.new(index_description) }

      before do
        other_index.validations << exclusion
        other_index.validations << inclusion
      end
      
      it { is_expected.to eq(other_index) }
    end

    describe "when description and validations list are the same" do
      let(:other_index) { described_class.new(index_description) }

      before do
        other_index.validations << inclusion
        other_index.validations << exclusion
      end
      
      it { is_expected.to eq(other_index) }
    end
  end
end