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
    ::ActiveRecord::Base.connection.class.send(
      :prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
    )
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

    context "with integers array" do
      let(:opts) { [1, 5] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: [1, 5], as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with integers closed range" do
      let(:opts) { 1..5 }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: 1..5, as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with integers open array" do
      let(:opts) { 1...5 }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: 1...5, as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with floats array" do
      let(:opts) { [1.1, 1.5] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: [1.1, 1.5], as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with floats closed range" do
      let(:opts) { 1.1..1.5 }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: 1.1..1.5, as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with floats oped range" do
      let(:opts) { 1.1...1.5 }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: 1.1...1.5, as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
    end

    describe "with regexp" do
      let(:opts) { /exp/ }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: { in: /exp/, as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with times array" do
      let(:opts) { [Time.new(2011, 1, 1, 1, 1, 1), Time.new(2012, 2, 2, 2, 2, 2)] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: [Time.new(2011, 1, 1, 1, 1, 1), Time.new(2012, 2, 2, 2, 2, 2)],"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2),"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with times closed range" do
      let(:opts) { Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 2),"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with datetimes array" do
      let(:opts) { [DateTime.new(2011, 1, 1, 1, 1, 1), DateTime.new(2012, 2, 2, 2, 2, 2)] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: [DateTime.new(2011, 1, 1, 1, 1, 1), DateTime.new(2012, 2, 2, 2, 2, 2)],"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1)..DateTime.new(2012, 2, 2, 2, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: DateTime.new(2011, 1, 1, 1, 1, 1)..DateTime.new(2012, 2, 2, 2, 2, 2),"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with datetimes closed range" do
      let(:opts) { DateTime.new(2011, 1, 1, 1, 1, 1)...DateTime.new(2012, 2, 2, 2, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: DateTime.new(2011, 1, 1, 1, 1, 1)...DateTime.new(2012, 2, 2, 2, 2, 2),"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with dates array" do
      let(:opts) { [Date.new(2011, 1, 1), Date.new(2012, 2, 2)] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\","\
          " exclusion: { in: [Date.new(2011, 1, 1), Date.new(2012, 2, 2)],"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)..Date.new(2012, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: Date.new(2011, 1, 1)..Date.new(2012, 2, 2),"\
          " as: :trigger, update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with dates closed range" do
      let(:opts) { Date.new(2011, 1, 1)...Date.new(2012, 2, 2) }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: Date.new(2011, 1, 1)...Date.new(2012, 2, 2),"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with strings array" do
      let(:opts) { ['str', 'str2'] }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: ['str', 'str2'],"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with strings closed range" do
      let(:opts) { 'str'..'str2' }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\","\
          " exclusion: { in: 'str'..'str2',"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with strings oped range" do
      let(:opts) { 'str'...'str2' }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "exclusion: {"\
          " in: 'str'...'str2',"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
      it_should_be_executable
    end

    context "with empty options hash" do
      let(:validation) {
        Mv::Core::Validation::Exclusion.new(:table_name, :column_name, {})
      }

      it { is_expected.to eq("validates(\"table_name\", \"column_name\", exclusion: true)") }
      it_should_be_executable
    end

    context 'for custom validation' do
      let(:validation) {
        Mv::Core::Validation::Custom.new(
               :table_name,
               :column_name,
               statement: "column_name IN ('str1', 'str2')",
               as: :trigger,
               update_trigger_name: :update_trigger_name
        )
      }

      it do
        is_expected.to eq(
          "validates(\"table_name\", \"column_name\", "\
          "custom: {"\
          " statement: 'column_name IN (\\'str1\\', \\'str2\\')',"\
          " as: :trigger,"\
          " update_trigger_name: :update_trigger_name })"
        )
      end
    end
  end
end
