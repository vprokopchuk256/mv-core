require 'spec_helper'

require 'mv/core/validation/active_model_presenter/factory'

describe Mv::Core::Validation::ActiveModelPresenter::Factory do
  subject(:factory) { described_class.new }

  describe "#create_presenter" do
    subject { factory.create_presenter(validation) }

    describe "exclusion" do
      let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
    end
   
    describe "inclusion" do
      let(:validation) { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Inclusion) }
    end 

    describe "length" do
      let(:validation) { Mv::Core::Validation::Length.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Length) }
    end

    describe "presence" do
      let(:validation) { Mv::Core::Validation::Presence.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Presence) }
    end

    describe "absence" do
      let(:validation) { Mv::Core::Validation::Absence.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Absence) }
    end

    describe "uniqueness" do
      let(:validation) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Uniqueness) }
    end

    describe "custom" do
      let(:validation) { Mv::Core::Validation::Custom.new(:table_name, :column_name, { statement: 'column_name > 0'}) }

      it { is_expected.to be_nil }
    end
  end

  describe "#register_presenter" do
    let(:klass) { CustomValidationPresenterClass = Class.new(Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
    let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

    before { factory.register_presenter(Mv::Core::Validation::Exclusion, klass) }

    subject { factory.create_presenter(validation) }

    it { is_expected.to be_an_instance_of(klass) }

    after { factory.register_presenter(Mv::Core::Validation::Exclusion, Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
  end

  describe "#register_presenters" do
    let(:klass) { CustomValidationPresenterClass1 = Class.new(Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
    let(:validation) { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

    before { factory.register_presenters(Mv::Core::Validation::Exclusion => klass) }

    subject { factory.create_presenter(validation) }

    it { is_expected.to be_an_instance_of(klass) }

    after { factory.register_presenters(Mv::Core::Validation::Exclusion => Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
  end
end