require 'spec_helper'

require 'mv/core/validation/inclusion'

describe Mv::Core::Validation::Inclusion do
  def instance(opts = {})
    described_class.new(:table_name, :column_name, 
                        { in: [1, 2], 
                        message: :message, 
                        on: :create, 
                        create_trigger_name: :create_trigger_name, 
                        update_trigger_name: :update_trigger_name, 
                        allow_nil: true, 
                        allow_blank: true, 
                        as: :check }.merge(opts))
  end

  subject { instance }

  describe "#initialize" do
    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:in) { is_expected.to eq([1, 2]) }
    its(:message) { is_expected.to eq(:message) }
    its(:on) { is_expected.to eq(:create) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to eq(true) }
    its(:allow_blank) { is_expected.to eq(true) }
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
      
      its(:message) { is_expected.to eq('Inclusion violated on the table table_name column column_name') }
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