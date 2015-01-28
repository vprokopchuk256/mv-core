require 'spec_helper'

require 'mv/core/validation/active_model_presenter/length'

describe Mv::Core::Validation::ActiveModelPresenter::Length do
  subject(:validation) { 
    Mv::Core::Validation::Length.new(:table_name, 
                                        :column_name, 
                                        opts)
  }

  subject(:acive_model_presenter) { described_class.new(validation) }

  describe "#initialize" do
    let(:opts) { { is: 1 } }

    its(:validation) { is_expected.to eq(validation) }
    its(:column_name) { is_expected.to eq(:column_name) }
  end

  describe "#options" do
    subject { acive_model_presenter.options }

    describe ":is" do
      let(:opts) { { is: 1 } }

      it { is_expected.to eq(length: { is: 1}) }
    end

    describe ":in" do
      let(:opts) { { in: [1, 3] } }

      it { is_expected.to eq(length: { in: [1, 3]}) }
    end

    describe ":within" do
      let(:opts) { { within: [1, 3] } }

      it { is_expected.to eq(length: { within: [1, 3]}) }
    end

    describe ":minimum & :maximum" do
      let(:opts) { { 
        minimum: 1, 
        maximum: 3, 
        too_long: :too_long, 
        too_short: :too_short
      } }

      it { is_expected.to eq(
        length: { minimum: 1, 
                  maximum: 3, 
                  too_long: :too_long, 
                  too_short: :too_short }
      ) }
    end

    describe "when properties has specified" do
      let(:opts) { {
        is: 1,
        on: :create, 
        as: :trigger, 
        allow_blank: true, 
        allow_nil: true, 
        message: 'some error message'
      } }

      it { is_expected.to eq(
        length: { is: 1,
                     on: :create, 
                     allow_blank: true, 
                     allow_nil: true,
                     message: 'some error message' }
      )}
    end

  end
end