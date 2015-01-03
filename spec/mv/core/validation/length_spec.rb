require 'spec_helper'

require 'mv/core/validation/length'

describe Mv::Core::Validation::Length do
  def instance(opts = {})
    table_name = opts.with_indifferent_access.delete(:table_name) || :table_name
    column_name = opts.with_indifferent_access.delete(:column_name) || :column_name
    described_class.new(table_name, column_name,
                        { is: 5, 
                        message: :message, 
                        too_long: :too_long, 
                        too_short: :too_short, 
                        on: :save, 
                        create_trigger_name: :create_trigger_name, 
                        update_trigger_name: :update_trigger_name, 
                        allow_nil: true,
                        allow_blank: true,
                        as: :trigger}.merge(opts))
  end

  subject { instance }

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:is) { is_expected.to eq(5) }
    its(:message) { is_expected.to eq(:message) }
    its(:too_long) { is_expected.to eq(:too_long) }
    its(:too_short) { is_expected.to eq(:too_short) }
    its(:on) { is_expected.to eq(:save) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to be_truthy }
    its(:allow_blank) { is_expected.to be_truthy }
    its(:as) { is_expected.to eq(:trigger) }

    describe ":in" do
      subject { instance(is: nil, in: [1, 2, 3]) }
      
      its(:in) { is_expected.to eq([1, 2, 3]) }
    end

    describe ":within" do
      subject { instance(is: nil, within: [1, 2, 3]) }

      its(:within) { is_expected.to eq([1, 2, 3]) }
    end

    describe ":maximum" do
      subject { instance(is: nil, maximum: 1) }

      its(:maximum) { is_expected.to eq(1) }
    end

    describe ":minimum" do
      subject { instance(is: nil, minimum: 1) }

      its(:minimum) { is_expected.to eq(1) }
    end
  end

  describe "#<==>" do
    it { is_expected.to eq(instance) }
    it { is_expected.to eq(instance({'table_name' => 'table_name',
                                     'column_name' => 'column_name',
                                    'is' => '5', 
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

    describe ":in" do
      subject { instance(is: nil, in: [1, 2, 3]) }
      
      it { is_expected.to eq(instance(is: nil, 'in' => [3, 2, 1])) }
      it { is_expected.not_to eq(instance(is: nil, 'in' => [1, 2, 3, 4])) }
    end

    describe ":within" do
      subject { instance(is: nil, within: [1, 2, 3]) }
      
      it { is_expected.to eq(instance(is: nil, 'within' => [3, 2, 1])) }
      it { is_expected.not_to eq(instance(is: nil, 'within' => [1, 2, 3, 4])) }
    end

    describe ":maximum" do
      subject { instance(is: nil, maximum: 1) }

      it { is_expected.to eq(instance(is: nil, 'maximum' => '1')) }
      it { is_expected.not_to eq(instance(is: nil, 'maximum' => '2')) }
    end

    describe ":minimum" do
      subject { instance(is: nil, minimum: 1) }

      it { is_expected.to eq(instance(is: nil, 'minimum' => '1')) }
      it { is_expected.not_to eq(instance(is: nil, 'minimum' => '2')) }
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
      
      its(:message) { is_expected.to eq('Length violated on the table table_name column column_name') }
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

    describe ":maximum" do
      describe "when empty" do
        subject { instance(maximum: nil) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(maximum: :non_numerical, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(maximum: 5.2, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(maximum: -5, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when defined at list one attr from the list: [:is, :within, :in]" do
        subject { instance(is: 5, maximum: 5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":minimum" do
      describe "when empty" do
        subject { instance(minimum: nil) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(minimum: :non_numerical, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(minimum: 5.2, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(minimum: -5, is: nil) }

        it { is_expected.to be_invalid }
      end

      describe "when defined at list one attr from the list: [:is, :within, :in]" do
        subject { instance(within: 1..5, maximum: 5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":is" do
      describe "when empty" do
        subject { instance(is: nil, minimum: 5) }

        it { is_expected.to be_valid }
      end

      describe "when non numerical" do
        subject { instance(is: :non_numerical, minimum: 5) }

        it { is_expected.to be_invalid }
      end

      describe "when not integer" do
        subject { instance(is: 5.2, minimum: 5) }

        it { is_expected.to be_invalid }
      end

      describe "when negative" do
        subject { instance(is: -5, minimum: 5) }

        it { is_expected.to be_invalid }
      end


      describe "when defined at list one attr from the list: [:within, :in, [:maximum, :minimum]]" do
        subject { instance(in: [5, 6], is: 5) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":in" do
      describe "when empty" do
        subject { instance(in: [], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when nil" do
        subject { instance(in: nil, is: 5) } 

        it { is_expected.to be_valid }
      end

      describe "when not array" do
        subject { instance(in: :some_not_array, is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is not an integer" do
        subject { instance(in: [1, :not_integer], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is negative" do
        subject { instance(in: [1, -1], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when range" do
        subject { instance(in: 1..3, is: nil) } 

        it { is_expected.to be_valid }
      end

      describe "when defined at list one attr from the list: [:is, :within, [:maximum, :minimum]]" do
        subject { instance(in: [5, 6], within: [1, 2, 4], is: nil) }

        it { is_expected.to be_invalid }
      end
    end

    describe ":within" do
      describe "when empty" do
        subject { instance(within: [], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when nil" do
        subject { instance(within: nil) } 

        it { is_expected.to be_valid }
      end

      describe "when not array" do
        subject { instance(within: :some_not_array, is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is not an integer" do
        subject { instance(within: [1, :not_integer], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when at least one item is negative" do
        subject { instance(in: [1, -1], is: nil) } 

        it { is_expected.to be_invalid }
      end

      describe "when range" do
        subject { instance(within: 1..3, is: nil) } 

        it { is_expected.to be_valid }
      end

      describe "when defined at list one attr from the list: [:is, [:maximum, :minimum], in]" do
        subject { instance(is: [5, 6], within: [1, 2, 4]) }

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