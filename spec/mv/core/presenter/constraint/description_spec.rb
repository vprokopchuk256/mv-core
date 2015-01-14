require 'spec_helper'

require 'mv/core/presenter/constraint/description'

describe Mv::Core::Presenter::Constraint::Description do
  let(:description) { Mv::Core::Constraint::Description.new(:trg_name, :trigger, opts)}

  subject(:presenter) { described_class.new(description) }

  describe "#initialize" do
    let(:opts) { {} }

    its(:description) { is_expected.to eq(description) }
  end

  describe "#to_s" do
    subject { "#{presenter}" }
    
    describe "when options hash is empty" do
      let(:opts) { {} }

      it { is_expected.to eq("trigger(\"trg_name\")") } 
    end

    describe "when options hash is not empty" do
      let(:opts) { { event: :create } }
      
      it { is_expected.to eq("trigger(\"trg_name\", event: :create)") } 
    end
  end
end