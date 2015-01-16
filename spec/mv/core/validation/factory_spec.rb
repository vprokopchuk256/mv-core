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

  describe "absence" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :absence, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Absence) }
    its(:as) { is_expected.to eq(:check) }
  end

  describe "when custom validation provided" do
    let(:klass) { TestClass = Class.new(Mv::Core::Validation::Uniqueness) }

    before { described_class.register_validation(:uniqueness, klass) }

    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :uniqueness, 
                                        { as: :check })}
    
    it { is_expected.to be_instance_of(klass) }

    after { described_class.register_validation(:uniqueness, Mv::Core::Validation::Uniqueness) }
  end

  describe "when custom validations provided" do
    let(:klass) { TestClass1 = Class.new(Mv::Core::Validation::Uniqueness) }

    before { described_class.register_validations(:uniqueness => klass) }

    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :uniqueness, 
                                        { as: :check })}
    
    it { is_expected.to be_instance_of(klass) }

    after { described_class.register_validations(:uniqueness => Mv::Core::Validation::Uniqueness) }
  end

  describe "when requested validation is not defined" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :unknown, 
                                        { as: :check })}

    it "raises an error" do
      expect{ subject }.to raise_error(Mv::Core::Error)
    end
  end
end