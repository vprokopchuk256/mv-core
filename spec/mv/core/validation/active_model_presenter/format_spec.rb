require 'spec_helper'

require 'mv/core/validation/active_model_presenter/format'

describe Mv::Core::Validation::ActiveModelPresenter::Format do
  subject(:validation) {
    Mv::Core::Validation::Format.new(:table_name,
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
      let(:opts) { { with: /txt/ } }

      it { is_expected.to eq(format: { with: /txt/}) }
    end

    describe "when properties has specified" do
      let(:opts) { {
        with: /txt/,
        on: :create,
        as: :trigger,
        allow_blank: true,
        allow_nil: true,
        message: 'some error message'
      } }

      it { is_expected.to eq(
        format: { with: /txt/,
                     on: :create,
                     allow_blank: true,
                     allow_nil: true,
                     message: 'some error message' }
      )}
    end

  end
end

