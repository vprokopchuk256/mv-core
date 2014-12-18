require 'spec_helper'

require 'mv/core/validation/length'

describe Mv::Core::Validation::Length do
  def instance(opts = {})
    described_class.new(:table_name, :column_name,
                        { in: [1, 2, 3], 
                        within: [1, 2, 3], 
                        is: 5, 
                        maximum: 1,
                        minimum: 0, 
                        message: :message, 
                        too_long: :too_long, 
                        too_short: :too_short, 
                        on: :create, 
                        create_trigger_name: :create_trigger_name, 
                        update_trigger_name: :update_trigger_name, 
                        allow_nil: true,
                        allow_blank: true,
                        as: :check}.merge(opts))
  end

  subject { instance }
  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:in) { is_expected.to eq([1, 2, 3]) }
    its(:within) { is_expected.to eq([1, 2, 3]) }
    its(:is) { is_expected.to eq(5) }
    its(:maximum) { is_expected.to eq(1) }
    its(:minimum) { is_expected.to eq(0) }
    its(:message) { is_expected.to eq(:message) }
    its(:too_long) { is_expected.to eq(:too_long) }
    its(:too_short) { is_expected.to eq(:too_short) }
    its(:on) { is_expected.to eq(:create) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to be_truthy }
    its(:allow_blank) { is_expected.to be_truthy }
    its(:as) { is_expected.to eq(:check) }
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
      
      its(:message) { is_expected.to eq('Length violated on the table table_name column column_name') }
    end

    describe ":on" do
      subject { instance(on: nil) } 

      its(:on) { is_expected.to eq(:save) }
    end

    describe ":as" do
      subject { instance(as: nil) } 

      its(:as) { is_expected.to eq(:trigger) }
    end

    describe ":create_trigger_name" do
      describe "when :on == :save" do
        subject { instance(on: :save, create_trigger_name: nil) }

        its(:create_trigger_name) { is_expected.to eq('trg_mv_table_name_ins') }
      end

      describe "when :on == :create" do
        subject { instance(on: :create, create_trigger_name: nil) }
        
        its(:create_trigger_name) { is_expected.to eq('trg_mv_table_name_ins') }
      end

      describe "when :on == :update" do
        subject { instance(on: :update, create_trigger_name: nil) }
        
        its(:create_trigger_name) { is_expected.to be_nil }
      end
    end

    describe ":update_trigger_name" do
      describe "when :on == :save" do
        subject { instance(on: :save, update_trigger_name: nil) }

        its(:update_trigger_name) { is_expected.to eq('trg_mv_table_name_upd') }
      end

      describe "when :on == :create" do
        subject { instance(on: :create, update_trigger_name: nil) }
        
        its(:update_trigger_name) { is_expected.to be_nil }
      end

      describe "when :on == :update" do
        subject { instance(on: :update, update_trigger_name: nil) }
        
        its(:update_trigger_name) { is_expected.to eq('trg_mv_table_name_upd') }
      end
    end
  end

  describe "validation" do
    it { is_expected.to be_valid }

    describe ":maximum" do
      describe "when empty" do
        subject { instance(maximum: nil) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(maximum: :non_numerical) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(maximum: 5.2) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(maximum: -5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":minimum" do
      describe "when empty" do
        subject { instance(minimum: nil) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(minimum: :non_numerical) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(minimum: 5.2) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(minimum: -5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":is" do
      describe "when empty" do
        subject { instance(is: nil) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(is: :non_numerical) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(is: 5.2) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(is: -5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":in" do
      describe "when empty" do
        subject { instance(in: []) } 

        it { is_expected.to be_invalid }
      end

      describe "when nil" do
        subject { instance(in: nil) } 

        it { is_expected.to be_valid }
      end

      describe "when not array" do
        subject { instance(in: :some_not_array) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is not an integer" do
        subject { instance(in: [1, :not_integer]) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is negative" do
        subject { instance(in: [1, -1]) } 

        it { is_expected.to be_invalid }
      end

      describe "when range" do
        subject { instance(in: 1..3) } 

        it { is_expected.to be_valid }
      end
    end

    describe ":within" do
      describe "when empty" do
        subject { instance(within: []) } 

        it { is_expected.to be_invalid }
      end

      describe "when nil" do
        subject { instance(within: nil) } 

        it { is_expected.to be_valid }
      end

      describe "when not array" do
        subject { instance(within: :some_not_array) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is not an integer" do
        subject { instance(within: [1, :not_integer]) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is negative" do
        subject { instance(in: [1, -1]) } 

        it { is_expected.to be_invalid }
      end

      describe "when range" do
        subject { instance(within: 1..3) } 

        it { is_expected.to be_valid }
      end
    end

    describe ":on" do
      [:save, :update, :create].each do |event|
        describe "when :on == #{event}" do
          subject { instance(on: event) }
         
          it { is_expected.to be_valid }
        end
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
      [:trigger, :check].each do |constraint_type|
        describe "when :as == #{constraint_type}" do
          subject { instance(as: constraint_type) }
         
          it { is_expected.to be_valid }
        end
      end

      describe "when :as == :invalid_constraint_type" do
        subject { instance(as: :invalid_constraint_type) }
       
        it { is_expected.to be_invalid }
      end
    end
  end
end