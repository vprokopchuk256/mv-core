require 'spec_helper'

require 'mv/core/validation/active_model_presenter/inclusion'

describe Mv::Core::Validation::ActiveModelPresenter::Inclusion do
  subject(:validation) { 
    Mv::Core::Validation::Inclusion.new(:table_name, 
                                        :column_name, 
                                        opts)
  }

  subject(:acive_model_presenter) { described_class.new(validation) }

  describe "#initialize" do
    let(:opts) { true }

    its(:validation) { is_expected.to eq(validation) }
    its(:column_name) { is_expected.to eq(:column_name) }
  end

  describe "#options" do
    subject { acive_model_presenter.options }

    describe "when empty properties has specified" do
      let(:opts) { { in: [1, 3] } }

      it { is_expected.to eq(inclusion: { in: [1, 3]}) }
    end

    describe "when properties has specified" do
      let(:opts) { {
        in: [1, 3],
        on: :create, 
        as: :trigger, 
        allow_blank: true, 
        allow_nil: true, 
        message: 'some error message'
      } }

      it { is_expected.to eq(
        inclusion: { in: [1, 3],
                     on: :create, 
                     allow_blank: true, 
                     allow_nil: true,
                     message: 'some error message' }
      )}
    end

  end
end