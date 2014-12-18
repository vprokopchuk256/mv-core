require 'spec_helper'

require 'mv/core/validation/format'

describe Mv::Core::Validation::Format do
  describe "#initialize" do
    subject { described_class.new(with: :with, 
                                  message: :message, 
                                  on: :on, 
                                  create_trigger_name: :create_trigger_name, 
                                  update_trigger_name: :update_trigger_name, 
                                  allow_nil: :allow_nil, 
                                  allow_blank: :allow_blank, 
                                  as: :as) }

    its(:with) { is_expected.to eq(:with) }
    its(:message) { is_expected.to eq(:message) }
    its(:on) { is_expected.to eq(:on) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to eq(:allow_nil) }
    its(:allow_blank) { is_expected.to eq(:allow_blank) }
    its(:as) { is_expected.to eq(:as) }
  end
  
end