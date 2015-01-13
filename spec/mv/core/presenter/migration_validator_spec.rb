require 'spec_helper'

require 'mv/core/presenter/migration_validator'

describe Mv::Core::Presenter::MigrationValidator do
  let(:migration_validator) { 
    build(:migration_validator, 
           table_name: :table_name, 
           column_name: :column_name, 
           validation_type: :exclusion, 
           options: { in: opts, as: :trigger, update_trigger_name: :update_trigger_name })
  }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:presenter) { described_class.new(migration_validator) }

  describe "#initialize" do
    let(:opts) { [1, 5] }

    its(:validator) { is_expected.to eq(migration_validator) }
  end

  describe "#to_s" do
    subject { "#{presenter}" }

    describe "with integers array" do
      let(:opts) { [1, 5] }
      
      it { is_expected.to eq("exclusion: { in: [1, 5], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with integers closed range" do
      let(:opts) { 1..5 }
      
      it { is_expected.to eq("exclusion: { in: 1..5, as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with integers open array" do
      let(:opts) { 1...5 }
      
      it { is_expected.to eq("exclusion: { in: 1...5, as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with floats array" do
      let(:opts) { [1.1, 1.5] }
      
      it { is_expected.to eq("exclusion: { in: [1.1, 1.5], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with floats closed range" do
      let(:opts) { 1.1..1.5 }
      
      it { is_expected.to eq("exclusion: { in: 1.1..1.5, as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with floats oped range" do
      let(:opts) { 1.1...1.5 }
      
      it { is_expected.to eq("exclusion: { in: 1.1...1.5, as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with regexp" do
      let(:opts) { /exp/ }
      
      it { is_expected.to eq("exclusion: { in: /exp/, as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with times array" do
      let(:opts) { [Time.new(2011, 1, 1, 1, 1, 1, '+02:00'), Time.new(2012, 2, 2, 2, 2, 2, '+02:00')] }
      
      it { is_expected.to eq("exclusion: { in: [Time.new(2011, 1, 1, 1, 1, 1, '+02:00'), Time.new(2012, 2, 2, 2, 2, 2, '+02:00')], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1, '+02:00')..Time.new(2012, 2, 2, 2, 2, 2, '+02:00') }
      
      it { is_expected.to eq("exclusion: { in: Time.new(2011, 1, 1, 1, 1, 1, '+02:00')..Time.new(2012, 2, 2, 2, 2, 2, '+02:00'), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1, '+02:00')...Time.new(2012, 2, 2, 2, 2, 2, '+02:00') }
      
      it { is_expected.to eq("exclusion: { in: Time.new(2011, 1, 1, 1, 1, 1, '+02:00')...Time.new(2012, 2, 2, 2, 2, 2, '+02:00'), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with datetimes array" do
      let(:opts) { [DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00'), DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00')] }
      
      it { is_expected.to eq("exclusion: { in: [DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00'), DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00')], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00')..DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00') }
      
      it { is_expected.to eq("exclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00')..DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00'), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00')...DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00') }
      
      it { is_expected.to eq("exclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1, '+02:00')...DateTime.new(2012, 2, 2, 2, 2, 2, '+02:00'), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with dates array" do
      let(:opts) { [Date.new(2011, 1, 1), Date.new(2012, 2, 2)] }
      
      it { is_expected.to eq("exclusion: { in: [Date.new(2011, 1, 1), Date.new(2012, 2, 2)], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)..Date.new(2012, 2, 2) }
      
      it { is_expected.to eq("exclusion: { in: Date.new(2011, 1, 1)..Date.new(2012, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)...Date.new(2012, 2, 2) }
      
      it { is_expected.to eq("exclusion: { in: Date.new(2011, 1, 1)...Date.new(2012, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with strings array" do
      let(:opts) { ['str', 'str2'] }
      
      it { is_expected.to eq("exclusion: { in: ['str', 'str2'], as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with strings closed range" do
      let(:opts) { 'str'..'str2' }
      
      it { is_expected.to eq("exclusion: { in: 'str'..'str2', as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end

    describe "with strings oped range" do
      let(:opts) { 'str'...'str2' }
      
      it { is_expected.to eq("exclusion: { in: 'str'...'str2', as: :trigger, update_trigger_name: :update_trigger_name }") } 
    end
  end
end