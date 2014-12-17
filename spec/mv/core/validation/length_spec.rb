require 'spec_helper'

require 'mv/core/validation/length'

describe Mv::Core::Validation::Length do
  describe "#initialize" do
    subject { described_class.new(in: :in, 
                                  within: :within, 
                                  is: :is, 
                                  maximum: :maximum, 
                                  minimum: :minimum, 
                                  message: :message, 
                                  too_long: :too_long, 
                                  too_short: :too_short, 
                                  on: :on, 
                                  create_trigger_name: :create_trigger_name, 
                                  update_trigger_name: :update_trigger_name, 
                                  allow_nil: :allow_nil, 
                                  allow_blank: :allow_blank, 
                                  as: :as) }

    its(:in) { is_expected.to eq(:in) }
    its(:within) { is_expected.to eq(:within) }
    its(:is) { is_expected.to eq(:is) }
    its(:maximum) { is_expected.to eq(:maximum) }
    its(:minimum) { is_expected.to eq(:minimum) }
    its(:message) { is_expected.to eq(:message) }
    its(:too_long) { is_expected.to eq(:too_long) }
    its(:too_short) { is_expected.to eq(:too_short) }
    its(:on) { is_expected.to eq(:on) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to eq(:allow_nil) }
    its(:allow_blank) { is_expected.to eq(:allow_blank) }
    its(:as) { is_expected.to eq(:as) }
  end
end