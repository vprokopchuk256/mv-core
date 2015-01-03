require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'

describe Mv::Core::Constraint::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
  end

  let(:index_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :index) }

  subject(:index) { described_class.new(index_description) }

  describe "#initialize" do
    its(:options) { is_expected.to eq({}) }
    its(:name) { is_expected.to eq(:idx_mv_table_name) }
    its(:validations) { is_expected.to eq([]) }
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

  describe "SQL methods" do
    before do
      if ActiveRecord::Base.connection.index_name_exists?(:table_name, :idx_mv_table_name, false)
        ActiveRecord::Base.connection.remove_index!(:table_name, :idx_mv_table_name)
      end

      Mv::Core::Migration::Base.with_suppressed_validations do
        ActiveRecord::Base.connection.drop_table(:table_name) if ActiveRecord::Base.connection.table_exists?(:table_name)

        ActiveRecord::Base.connection.create_table(:table_name) do |t|
          t.string :column_name
          t.string :column_name_1
        end
      end
    end

    let(:uniqueness) { 
      Mv::Core::Validation::Uniqueness.new(:table_name, 
                                           :column_name, 
                                           as: :index, 
                                           index_name: :idx_mv_table_name) 
    }

    before do
      index.validations << uniqueness
    end

    describe "#create" do
      before { index.create }

      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      it { is_expected.to be_present }
      its(:name) { is_expected.to eq('idx_mv_table_name')}
      its(:columns) { is_expected.to eq(['column_name'])}

      describe 'when called second time' do
        before do
          index.validations << Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                                               :column_name_1, 
                                                                               as: :index, 
                                                                               index_name: :idx_mv_table_name) 
          index.create
        end

        its(:columns) { is_expected.to eq(['column_name', 'column_name_1'])}
      end
    end

    describe "#update" do
      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      describe "when index exists" do
        before do 
          index.create 
          index.validations << Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                                               :column_name_1, 
                                                                               as: :index, 
                                                                               index_name: :idx_mv_table_name) 
          index.update(index)
        end

        its(:columns) { is_expected.to eq(['column_name', 'column_name_1'])}
      end

      describe "when index does not exist" do
        before do
          index.update(index)
        end
        
        it { is_expected.to be_present }
      end
    end

    describe "#delete" do
      before { 
        ActiveRecord::Base.connection.add_index(:table_name, :column_name, name: :idx_mv_table_name) 
        index.delete
      }

      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      it { is_expected.to be_nil }

      describe "when called second time" do
        it "should not raise error"  do
          expect{ index.delete }.not_to raise_error
        end
      end
    end
  end
end