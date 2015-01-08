require 'spec_helper'

require 'mv/core/validation/builder/factory'

describe Mv::Core::Validation::Builder::Factory do
  subject(:factory) { described_class.new }

  describe "#create_builder" do
    subject { factory.create_builder(validation) }

    describe "exclusion" do
      let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::Builder::Exclusion) }
    end
   
    describe "inclusion" do
      let(:validation) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::Builder::Inclusion) }
    end 

    describe "length" do
      let(:validation) { Mv::Core::Validation::Length.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::Builder::Length) }
    end

    describe "presence" do
      let(:validation) { Mv::Core::Validation::Presence.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::Builder::Presence) }
    end

    describe "uniqueness" do
      let(:validation) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::Builder::Uniqueness) }
    end
  end

  describe "#register_builder" do
    let(:klass) { CustomValidationBuilderClass = Class.new(Mv::Core::Validation::Builder::Exclusion) }
    let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

    before { factory.register_builder(Mv::Core::Validation::Exclusion, klass) }

    subject { factory.create_builder(validation) }

    it { is_expected.to be_an_instance_of(klass) }

    after { factory.register_builder(Mv::Core::Validation::Exclusion, Mv::Core::Validation::Builder::Exclusion) }
  end
end