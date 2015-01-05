require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/constraint/index'
require 'mv/core/error'
require 'mv/core/constraint/builder/index'

describe Mv::Core::Constraint::Builder::Index do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
  end

  let(:index_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :index) }
  let(:index_constraint) { Mv::Core::Constraint::Index.new(index_description) }
  let(:uniqueness) { 
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name, 
                                         as: :index, 
                                         index_name: :idx_mv_table_name) 
  }

  before do
    index_constraint.validations << uniqueness
  end

  subject(:index_builder) { described_class.new(index_constraint) }

  describe "#initialization" do
    its(:constraint) { is_expected.to eq(index_constraint) }
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

    describe "#create" do
      before { index_builder.create }

      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      it { is_expected.to be_present }
      its(:name) { is_expected.to eq('idx_mv_table_name')}
      its(:columns) { is_expected.to eq(['column_name'])}

      describe 'when called second time' do
        before do
          index_constraint.validations << Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                                               :column_name_1, 
                                                                               as: :index, 
                                                                               index_name: :idx_mv_table_name) 
          index_builder.create
        end

        its(:columns) { is_expected.to eq(['column_name', 'column_name_1'])}
      end
    end

    describe "#update" do
      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      describe "when index exists" do
        before do 
          index_builder.create 
          index_constraint.validations << Mv::Core::Validation::Uniqueness.new(:table_name, 
                                                                               :column_name_1, 
                                                                               as: :index, 
                                                                               index_name: :idx_mv_table_name) 
          index_builder.update(index_constraint)
        end

        its(:columns) { is_expected.to eq(['column_name', 'column_name_1'])}
      end

      describe "when index does not exist" do
        before do
          index_builder.update(index_builder)
        end
        
        it { is_expected.to be_present }
      end
    end

    describe "#delete" do
      before { 
        ActiveRecord::Base.connection.add_index(:table_name, :column_name, name: :idx_mv_table_name) 
        index_builder.delete
      }

      subject { ActiveRecord::Base.connection.indexes(:table_name).find{|idx| idx.name == "idx_mv_table_name"} }

      it { is_expected.to be_nil }

      describe "when called second time" do
        it "should not raise error"  do
          expect{ index_builder.delete }.not_to raise_error
        end
      end
    end
  end
end