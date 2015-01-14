require 'spec_helper'

require 'mv/core/presenter/validation/base'

describe Mv::Core::Presenter::Validation::Base do
  let(:validation) { 
    Mv::Core::Validation::Exclusion.new(
           :table_name, 
           :column_name, 
           in: opts, 
           as: :trigger, 
           update_trigger_name: :update_trigger_name
    )
  }

  before do
    ::ActiveRecord::Base.connection.class.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator)
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  subject(:presenter) { described_class.new(validation) }

  describe "#initialize" do
    let(:opts) { [1, 5] }

    its(:validation) { is_expected.to eq(validation) }
  end

  def self.it_should_be_executable
    it "should not raise and error when loaded in schema" do
      expect{ ActiveRecord::Base::connection.instance_eval(subject) }.not_to raise_error
    end
  end

  describe "#to_s" do
    subject { "#{presenter}" }

    describe "with integers array" do
      let(:opts) { [1, 5] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: [1, 5], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with integers closed range" do
      let(:opts) { 1..5 }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 1..5, as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with integers open array" do
      let(:opts) { 1...5 }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 1...5, as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with floats array" do
      let(:opts) { [1.1, 1.5] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: [1.1, 1.5], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with floats closed range" do
      let(:opts) { 1.1..1.5 }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 1.1..1.5, as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with floats oped range" do
      let(:opts) { 1.1...1.5 }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 1.1...1.5, as: :trigger, update_trigger_name: :update_trigger_name })") } 
    end

    describe "with regexp" do
      let(:opts) { /exp/ }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: /exp/, as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with times array" do
      let(:opts) { [Time.new(2011, 1, 1, 1, 1, 1), Time.new(2012, 2, 2, 2, 2, 2)] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: [Time.new(2011, 1, 1, 1, 1, 1), Time.new(2012, 2, 2, 2, 2, 2)], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with datetimes array" do
      let(:opts) { [DateTime.new(2011, 1, 1, 1, 1, 1), DateTime.new(2012, 2, 2, 2, 2, 2)] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: [DateTime.new(2011, 1, 1, 1, 1, 1), DateTime.new(2012, 2, 2, 2, 2, 2)], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1)..DateTime.new(2012, 2, 2, 2, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1)..DateTime.new(2012, 2, 2, 2, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1)...DateTime.new(2012, 2, 2, 2, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1)...DateTime.new(2012, 2, 2, 2, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with dates array" do
      let(:opts) { [Date.new(2011, 1, 1), Date.new(2012, 2, 2)] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: [Date.new(2011, 1, 1), Date.new(2012, 2, 2)], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)..Date.new(2012, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: Date.new(2011, 1, 1)..Date.new(2012, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)...Date.new(2012, 2, 2) }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: Date.new(2011, 1, 1)...Date.new(2012, 2, 2), as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with strings array" do
      let(:opts) { ['str', 'str2'] }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: ['str', 'str2'], as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with strings closed range" do
      let(:opts) { 'str'..'str2' }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 'str'..'str2', as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with strings oped range" do
      let(:opts) { 'str'...'str2' }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: { in: 'str'...'str2', as: :trigger, update_trigger_name: :update_trigger_name })") } 
      it_should_be_executable
    end

    describe "with empty options hash" do
      let(:validation) { 
        Mv::Core::Validation::Exclusion.new(:table_name, :column_name, {})
      }
      
      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: true)") }
      it_should_be_executable
    end
  end
end