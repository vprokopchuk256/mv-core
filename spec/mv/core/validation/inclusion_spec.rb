require 'spec_helper'

require 'mv/core/validation/inclusion'

describe Mv::Core::Validation::Inclusion do
  def instance(opts = {})
    table_name = opts.with_indifferent_access.delete(:table_name) || :table_name
    column_name = opts.with_indifferent_access.delete(:column_name) || :column_name
    described_class.new(table_name, column_name,
                        { in: [1, 2],
                        message: :message,
                        on: :save,
                        create_trigger_name: :create_trigger_name,
                        update_trigger_name: :update_trigger_name,
                        allow_nil: true,
                        allow_blank: true,
                        as: :trigger }.with_indifferent_access.merge(opts))
  end

  subject { instance }

  describe "#initialize" do
    describe "by default" do
      its(:table_name) { is_expected.to eq(:table_name) }
      its(:column_name) { is_expected.to eq(:column_name) }
      its(:in) { is_expected.to eq([1, 2]) }
      its(:message) { is_expected.to eq(:message) }
      its(:on) { is_expected.to eq(:save) }
      its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
      its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
      its(:allow_nil) { is_expected.to eq(true) }
      its(:allow_blank) { is_expected.to eq(true) }
      its(:as) { is_expected.to eq(:trigger) }
    end

    describe "when simplification provided" do
      subject { described_class.new(:table_name, :column_name, [1, 2])}

      its(:in) { is_expected.to eq([1, 2]) }
    end
  end

  describe "#<==>" do
    it { is_expected.to eq(instance) }
    it { is_expected.to eq(instance({'table_name' => 'table_name',
                                     'column_name' => 'column_name',
                                     'in' => [1, 2],
                                    'message' => 'message',
                                    'on' => 'save',
                                    'create_trigger_name' => 'create_trigger_name',
                                    'update_trigger_name' => 'update_trigger_name',
                                    'allow_nil' => true,
                                    'allow_blank' => true,
                                    'as' => 'trigger' } )) }

    it { is_expected.not_to eq(instance(table_name: 'table_name_1')) }
    it { is_expected.not_to eq(instance(column_name: 'column_name_1')) }
    it { is_expected.not_to eq(instance(message: 'some_other_message')) }
    it { is_expected.not_to eq(instance(on: 'create')) }
    it { is_expected.not_to eq(instance(create_trigger_name: 'some_other_create_trigger_name')) }
    it { is_expected.not_to eq(instance(update_trigger_name: 'some_other_update_trigger_name')) }
    it { is_expected.not_to eq(instance(allow_nil: false)) }
    it { is_expected.not_to eq(instance(allow_blank: false)) }
    it { is_expected.not_to eq(instance(as: :index)) }


    it { is_expected.to eq(instance(in: [2, 1])) }
    it { is_expected.not_to eq(instance(in: [1, 2, 3])) }

    describe "when in defined as non enumerable range" do
      subject { instance(in: Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2)) }

      it { is_expected.to eq(instance(in: Time.new(2011, 1, 1, 1, 1, 1)..Time.new(2012, 2, 2, 2, 2, 2))) }
      it { is_expected.not_to eq(instance(in: Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 2))) }
      it { is_expected.not_to eq(instance(in: Time.new(2011, 1, 1, 1, 1, 1)...Time.new(2012, 2, 2, 2, 2, 3))) }
    end
  end

  describe "default values" do
    describe ":allow_nil" do
      subject { instance(allow_nil: nil) }

      its(:allow_nil) { is_expected.to be_falsey }
    end

    describe ":allow_blank" do
      subject { instance(allow_blank: nil) }

      its(:allow_blank) { is_expected.to be_falsey }
    end

    describe ":message" do
      subject { instance(message: nil) }

      its(:message) { is_expected.to eq('is not included in the list') }
      its(:full_message) { is_expected.to eq('column_name is not included in the list') }
    end

    describe ":on" do
      describe "when :as == :trigger" do
        subject { instance(on: nil, as: :trigger) }

        its(:on) { is_expected.to eq(:save) }
      end
    end

    describe ":as" do
      subject { instance(as: nil) }

      its(:as) { is_expected.to eq(:trigger) }
    end

    describe ":create_trigger_name" do
      describe "when :as == :trigger" do
        subject { instance(create_trigger_name: nil, as: :trigger) }

        its(:create_trigger_name) { is_expected.to eq('trg_mv_table_name_ins') }
      end

      describe "when :on == :update" do
        subject { instance(create_trigger_name: nil, on: :update) }

        its(:create_trigger_name) { is_expected.to be_nil }
      end
    end

    describe ":update_trigger_name" do
      describe "when :as == :trigger" do
        subject { instance(update_trigger_name: nil, as: :trigger) }

        its(:update_trigger_name) { is_expected.to eq('trg_mv_table_name_upd') }
      end

      describe "when :on == :create" do
        subject { instance(update_trigger_name: nil, on: :create) }

        its(:update_trigger_name) { is_expected.to be_nil }
      end
    end
  end

  describe "validation" do
    it { is_expected.to be_valid }


    describe ":create_trigger_name" do
      describe "when :on == :update" do
        subject { instance(create_trigger_name: :trigger_name, update_trigger_name: nil, on: :update) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":update_trigger_name" do
      describe "when :on == :create" do
        subject { instance(update_trigger_name: :trigger_name, create_trigger_name: nil, on: :create) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":in" do
      describe "when empty" do
        subject { instance(in: []) }

        it { is_expected.to be_invalid }
      end

      describe "when can not be converted to array" do
        subject { instance(in: :not_array) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":on" do
      describe "when :on == :save" do
        subject { instance(on: :save) }

        it { is_expected.to be_valid }
      end

      describe "when :on == :update" do
        subject { instance(on: :update, create_trigger_name: nil) }

        it { is_expected.to be_valid }
      end

      describe "when :on == :create" do
        subject { instance(on: :create, update_trigger_name: nil) }

        it { is_expected.to be_valid }
      end

      describe "when :on == :invalid_event" do
        subject { instance(on: :invalid_event) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":allow_nil" do
      [true, false].each do |value|
        describe "when :allow_nil == #{value}" do
          subject { instance(allow_nil: value) }

          it { is_expected.to be_valid }
        end
      end

      describe "when :allow_nil == :non_boolean_value" do
        subject { instance(allow_nil: :non_boolean_value) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":allow_blank" do
      [true, false].each do |value|
        describe "when :allow_blank == #{value}" do
          subject { instance(allow_blank: value) }

          it { is_expected.to be_valid }
        end
      end

      describe "when :allow_blank == :non_boolean_value" do
        subject { instance(allow_blank: :non_boolean_value) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":as" do
      describe "when :as == :invalid_constraint_type" do
        subject { instance(as: :invalid_constraint_type, create_trigger_name: nil, update_trigger_name: nil) }

        it { is_expected.to be_invalid }
      end
    end
  end
end
