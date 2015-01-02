require 'spec_helper'

require 'mv/core/validation/factory'

describe Mv::Core::Validation::Factory do
  subject(:factory) { described_class }

  describe "exclusion" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :exclusion, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Exclusion) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "uniqueness" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :uniqueness, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Uniqueness) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "format" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :format, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Format) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "inclusion" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :inclusion, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Inclusion) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "length" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :length, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Length) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "presence" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :presence, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Presence) }
    its(:as) { is_expected.to eq(:check) }
  end
  
end