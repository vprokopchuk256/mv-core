require 'spec_helper'

require 'mv/core/validation/inclusion'

describe Mv::Core::Validation::Inclusion do
  describe "#initialize" do
    subject { described_class.new(:table_name,
                                  :column_name, 
                                  in: :in, 
                                  message: :message, 
                                  on: :on, 
                                  create_trigger_name: :create_trigger_name, 
                                  update_trigger_name: :update_trigger_name, 
                                  allow_nil: :allow_nil, 
                                  allow_blank: :allow_blank, 
                                  as: :as) }

    its(:table_name) { is_expected.to eq(:table_name) }
    its(:column_name) { is_expected.to eq(:column_name) }
    its(:in) { is_expected.to eq(:in) }
    its(:message) { is_expected.to eq(:message) }
    its(:on) { is_expected.to eq(:on) }
    its(:create_trigger_name) { is_expected.to eq(:create_trigger_name) }
    its(:update_trigger_name) { is_expected.to eq(:update_trigger_name) }
    its(:allow_nil) { is_expected.to eq(:allow_nil) }
    its(:allow_blank) { is_expected.to eq(:allow_blank) }
    its(:as) { is_expected.to eq(:as) }
  end
end