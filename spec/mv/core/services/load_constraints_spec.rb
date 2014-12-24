require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/services/load_constraints'
require 'mv/core/validation/uniqueness'

describe Mv::Core::Services::LoadConstraints do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#initialize" do
    subject { described_class.new([:table_1, :table_2]) } 

    its(:tables) { is_expected.to match_array([:table_1, :table_2]) }
  end

  describe "#execute" do

    describe "1 migration validator, 1 validation => 1 constraint" do
      let!(:migration_validator_check) { 
        create(:migration_validator, table_name: :table_name, 
                                     column_name: :column_name, 
                                     validation_type: :uniqueness,
                                     options: { as: :check })
      }

      subject(:constraints) { described_class.new([:table_name]).execute.sort } 

      its(:length) { is_expected.to eq(1) }

      describe "first constraint" do
        subject { constraints.first }

        its(:description) { is_expected.to eq(Mv::Core::Constraint::Description.new(:chk_mv_table_name_column_name, :check)) }

        its(:validations) { is_expected.to match_array([
          Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :check)
        ])}

      end
    end

    describe "1 migration validator, 2 validations => 2 constraints" do
      let!(:migration_validator_trigger) { 
        create(:migration_validator, table_name: :table_name, 
                                     column_name: :column_name, 
                                     options: { as: :trigger, on: :save })
      }
      
      subject(:constraints) { described_class.new([:table_name]).execute.sort } 

      its(:length) { is_expected.to eq(2) }

      describe "first constraint" do
        subject { constraints.first }

        its(:description) { is_expected.to eq(Mv::Core::Constraint::Description.new(:trg_mv_table_name_ins, :trigger, event: :create)) }

        its(:validations) { is_expected.to match_array([
          Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :trigger, on: :save)
        ])}
      end

      describe "second constraint" do
        subject { constraints.second }

        its(:description) { is_expected.to eq(Mv::Core::Constraint::Description.new(:trg_mv_table_name_upd, :trigger, event: :update)) }
        
        its(:validations) { is_expected.to match_array([
          Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :trigger, on: :save)
        ])}
      end
    end

    describe "2 migration validators, 2 validations => 2 constraints" do
      let!(:migration_validator_check) { 
        create(:migration_validator, table_name: :table_name, 
                                     column_name: :column_name, 
                                     options: { as: :check })
      }

      let!(:migration_validator_index) { 
        create(:migration_validator, table_name: :table_name_1, 
                                     column_name: :column_name, 
                                     options: { as: :index })
      }

      subject(:constraints) { described_class.new([:table_name, :table_name_1]).execute.sort } 
      
      its(:length) { is_expected.to eq(2) }

      describe "first constraint" do
        subject { constraints.first }

        its(:description) { is_expected.to eq(Mv::Core::Constraint::Description.new(:chk_mv_table_name_column_name, :check)) }

        its(:validations) { is_expected.to match_array([
          Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, as: :check)
        ])}
      end

      describe "second constraint" do
        subject { constraints.second }
        
        its(:description) { is_expected.to eq(Mv::Core::Constraint::Description.new(:idx_mv_table_name_1_column_name_uniq, :index)) }

        its(:validations) { is_expected.to match_array([
          Mv::Core::Validation::Uniqueness.new(:table_name_1, :column_name, as: :index)
        ])}
      end

      describe "when one table is filtered out" do
        subject { described_class.new([:table_name]).execute } 
        
        its(:length) { is_expected.to eq(1) }
      end
    end
  end
end